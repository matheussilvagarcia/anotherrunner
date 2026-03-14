import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health/health.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:anotherrunner/l10n/app_localizations.dart';
import 'auth_service.dart';
import 'package:anotherrunner/run_screen.dart';
import 'history_screen.dart';
import 'daily_history_screen.dart';
import 'chart_screen.dart';
import 'main.dart';
import 'purchase_service.dart';
import 'credits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<StepCount> _stepCountStream;
  int _stepsToday = 0;
  int _savedStepsCount = 0;
  int _lastLocalSteps = 0;
  String _lastSavedDate = '';

  Map<String, int> _localHourlyBuckets = {};
  Map<String, int> _healthHourlyBuckets = {};

  String _lastSyncText = 'Never';
  bool _isSyncing = false;

  double _realRunningTimeMin = 0.0;
  double _realRunningCalories = 0.0;
  bool _usingHealthData = false;

  bool _isRunActive = false;
  int _runSeconds = 0;
  double _runDistance = 0.0;
  StreamSubscription<Map<String, dynamic>?>? _serviceSubscription;

  @override
  void initState() {
    super.initState();
    _initPedometer();
    _loadLastSyncAndAutoSync();
    _checkForActiveRun();
    _listenToService();
  }

  @override
  void dispose() {
    _serviceSubscription?.cancel();
    super.dispose();
  }

  void _listenToService() {
    _serviceSubscription = FlutterBackgroundService().on('update').listen((event) {
      if (event == null || !mounted) return;

      setState(() {
        if (event.containsKey('isRunActive') && event['isRunActive'] == false) {
          _isRunActive = false;
        } else {
          if (event.containsKey('seconds')) {
            _runSeconds = (event['seconds'] as num).toInt();
            _isRunActive = true;
          }
          if (event.containsKey('distance')) {
            _runDistance = (event['distance'] as num).toDouble();
          }
        }
      });
    });
  }

  Future<void> _checkForActiveRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunActive = prefs.getBool('isRunActive') ?? false;

    setState(() {
      _isRunActive = isRunActive;
      if (_isRunActive) {
        _runSeconds = prefs.getInt('runSeconds') ?? 0;
        _runDistance = prefs.getDouble('runDistance') ?? 0.0;
      }
    });
  }

  Future<void> _loadLastSyncAndAutoSync() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastSyncText = prefs.getString('lastSyncText') ?? 'Never';
    });

    final lastSyncDateStr = prefs.getString('lastSyncDateString') ?? '';
    final todayStr = DateTime.now().toString().substring(0, 10);

    if (lastSyncDateStr != todayStr) {
      _syncToCloud();
    }
  }

  int _calculateTotalSteps() {
    int total = 0;
    String todayStr = DateTime.now().toString().substring(0, 10);
    Set<String> allKeys = {..._localHourlyBuckets.keys, ..._healthHourlyBuckets.keys};

    for (String key in allKeys) {
      if (key.startsWith(todayStr)) {
        int local = _localHourlyBuckets[key] ?? 0;
        int health = _healthHourlyBuckets[key] ?? 0;
        total += max(local, health);
      }
    }
    return total;
  }

  Future<void> _initPedometer() async {
    final prefs = await SharedPreferences.getInstance();
    _savedStepsCount = prefs.getInt('savedStepsCount') ?? 0;
    _lastSavedDate = prefs.getString('lastSavedDate') ?? '';
    _lastLocalSteps = prefs.getInt('lastLocalSteps') ?? 0;

    final String localBucketsStr = prefs.getString('localHourlyBuckets') ?? '{}';
    final String healthBucketsStr = prefs.getString('healthHourlyBuckets') ?? '{}';
    _localHourlyBuckets = Map<String, int>.from(jsonDecode(localBucketsStr));
    _healthHourlyBuckets = Map<String, int>.from(jsonDecode(healthBucketsStr));

    _realRunningTimeMin = prefs.getDouble('realRunningTimeMin') ?? 0.0;
    _realRunningCalories = prefs.getDouble('realRunningCalories') ?? 0.0;
    _usingHealthData = prefs.getBool('usingHealthData') ?? false;

    final currentDate = DateTime.now().toString().substring(0, 10);
    if (_lastSavedDate.isNotEmpty && _lastSavedDate != currentDate) {
      _usingHealthData = false;
      _realRunningTimeMin = 0.0;
      _realRunningCalories = 0.0;
      _stepsToday = 0;
      _lastLocalSteps = 0;
      _localHourlyBuckets.clear();
      _healthHourlyBuckets.clear();

      await prefs.setBool('usingHealthData', false);
      await prefs.setDouble('realRunningTimeMin', 0.0);
      await prefs.setDouble('realRunningCalories', 0.0);
      await prefs.setInt('lastKnownStepsToday', 0);
      await prefs.setInt('lastLocalSteps', 0);
      await prefs.setString('localHourlyBuckets', '{}');
      await prefs.setString('healthHourlyBuckets', '{}');
    }

    _stepsToday = _calculateTotalSteps();

    if (mounted) {
      setState(() {});
    }

    Map<Permission, PermissionStatus> statuses = await [
      Permission.activityRecognition,
      Permission.sensors,
    ].request();

    if (statuses[Permission.activityRecognition]!.isGranted ||
        statuses[Permission.sensors]!.isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    }
  }

  Future<void> _syncWithHealthConnect() async {
    final l10n = AppLocalizations.of(context)!;
    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.TOTAL_CALORIES_BURNED,
      HealthDataType.WORKOUT,
      HealthDataType.DISTANCE_DELTA,
    ];

    try {
      Health().configure();
      bool authorized = await Health().requestAuthorization(types);

      if (authorized) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);
        final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

        for (int i = 0; i <= now.hour; i++) {
          DateTime start = midnight.add(Duration(hours: i));
          DateTime end = midnight.add(Duration(hours: i + 1));
          if (end.isAfter(now)) end = now;

          int? stepsInHour = await Health().getTotalStepsInInterval(start, end);
          String hourKey = start.toString().substring(0, 13);
          _healthHourlyBuckets[hourKey] = stepsInHour ?? 0;
        }

        List<HealthDataPoint> workoutData = await Health().getHealthDataFromTypes(
          types: [HealthDataType.WORKOUT],
          startTime: midnight,
          endTime: endOfDay,
        );

        double tempRunningTime = 0.0;
        double tempRunningCalories = 0.0;
        final user = FirebaseAuth.instance.currentUser;

        for (var point in workoutData) {
          if (point.value is WorkoutHealthValue) {
            var workout = point.value as WorkoutHealthValue;

            if (workout.workoutActivityType == HealthWorkoutActivityType.RUNNING) {
              final durationMillis = point.dateTo.millisecondsSinceEpoch - point.dateFrom.millisecondsSinceEpoch;
              final durationSeconds = durationMillis ~/ 1000;
              final calories = workout.totalEnergyBurned ?? 0.0;

              final distanceMeters = workout.totalDistance ?? 0.0;
              final distanceKm = distanceMeters / 1000.0;

              double averagePace = 0.0;
              if (distanceKm > 0) {
                averagePace = (durationSeconds / 60.0) / distanceKm;
              }

              if (point.dateFrom.isAfter(midnight)) {
                tempRunningTime += (durationMillis / 1000) / 60;
                tempRunningCalories += calories;
              }

              if (user != null) {
                final docId = 'hc_${point.dateFrom.millisecondsSinceEpoch}';
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .collection('runs')
                    .doc(docId)
                    .set({
                  'timestamp': Timestamp.fromDate(point.dateFrom),
                  'durationSeconds': durationSeconds,
                  'distanceKm': distanceKm,
                  'averagePace': averagePace,
                  'calories': calories,
                  'route': [],
                  'source': 'health_connect',
                }, SetOptions(merge: true));
              }
            }
          }
        }

        setState(() {
          _stepsToday = _calculateTotalSteps();
          _realRunningTimeMin = tempRunningTime;
          _realRunningCalories = tempRunningCalories;
          _usingHealthData = true;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('lastKnownStepsToday', _stepsToday);
        await prefs.setString('healthHourlyBuckets', jsonEncode(_healthHourlyBuckets));
        await prefs.setDouble('realRunningTimeMin', _realRunningTimeMin);
        await prefs.setDouble('realRunningCalories', _realRunningCalories);
        await prefs.setBool('usingHealthData', _usingHealthData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.hcSyncSuccess)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.hcPermissionDenied)),
          );
        }
      }
    } catch (e) {
      debugPrint("Health exception: $e");
    }
  }

  Future<void> _syncHistoricalDay(String dateStr, int steps, double calories, double timeMin) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || steps <= 0) return;

    final distance = steps * 0.000762;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .doc(dateStr)
          .set({
        'date': dateStr,
        'steps': steps,
        'distanceKm': distance,
        'calories': calories,
        'timeMin': timeMin,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {}
  }

  Future<void> _syncToCloud() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final dateStr = DateTime.now().toString().substring(0, 10);
      final distance = _stepsToday * 0.000762;

      final caloriesToSave = _usingHealthData && _realRunningCalories > 0
          ? _realRunningCalories
          : (_stepsToday * 0.04);

      final timeToSave = _usingHealthData && _realRunningTimeMin > 0
          ? _realRunningTimeMin
          : (_stepsToday / 100);

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('daily_stats')
            .doc(dateStr)
            .set({
          'date': dateStr,
          'steps': _stepsToday,
          'distanceKm': distance,
          'calories': caloriesToSave,
          'timeMin': timeToSave,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        final now = DateTime.now();
        final formattedSync = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} at ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('lastSyncText', formattedSync);
        await prefs.setString('lastSyncDateString', dateStr);

        if (mounted) {
          setState(() {
            _lastSyncText = formattedSync;
          });
        }
      } catch (e) {}
    }

    if (mounted) {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _manualSync() async {
    final l10n = AppLocalizations.of(context)!;
    await _syncToCloud();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.syncSuccess)),
      );
    }
  }

  Future<void> _handleLogout() async {
    await _syncToCloud();

    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode');
    final lang = prefs.getString('languageCode');

    await prefs.clear();

    if (isDark != null) await prefs.setBool('isDarkMode', isDark);
    if (lang != null) await prefs.setString('languageCode', lang);

    await AuthService().signOut();
  }

  Future<void> _deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir conta?'),
        content: const Text('Isso apagará todos os seus dados. Tem certeza?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continuar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm1 != true || !mounted) return;

    final confirm2 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aviso Final'),
        content: const Text('Esta ação é irreversível. Todas as suas corridas, histórico de passos e perfil serão apagados permanentemente do servidor.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir Definitivamente', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm2 != true || !mounted) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final batch = FirebaseFirestore.instance.batch();

      final runsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('runs')
          .get();
      for (var doc in runsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final statsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .get();
      for (var doc in statsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(FirebaseFirestore.instance.collection('users').doc(user.uid));

      await batch.commit();

      await user.delete();

      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDarkMode');
      final lang = prefs.getString('languageCode');
      await prefs.clear();
      if (isDark != null) await prefs.setBool('isDarkMode', isDark);
      if (lang != null) await prefs.setString('languageCode', lang);

      if (mounted) {
        Navigator.pop(context);
        await AuthService().signOut();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao excluir conta. Faça login novamente e tente de novo.')),
        );
      }
    }
  }

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final currentDateStr = DateTime.now().toString();
    final currentDate = currentDateStr.substring(0, 10);
    final currentHourKey = currentDateStr.substring(0, 13);

    if (event.steps < _savedStepsCount) {
      _savedStepsCount = 0;
      _lastLocalSteps = 0;
      await prefs.setInt('savedStepsCount', _savedStepsCount);
      await prefs.setInt('lastLocalSteps', _lastLocalSteps);
    }

    if (_lastSavedDate != currentDate) {
      if (_lastSavedDate.isNotEmpty) {
        final lastKnownSteps = prefs.getInt('lastKnownStepsToday') ?? 0;
        final estimatedCal = lastKnownSteps * 0.04;
        final estimatedTime = lastKnownSteps / 100.0;
        await _syncHistoricalDay(_lastSavedDate, lastKnownSteps, estimatedCal, estimatedTime);
      }

      _savedStepsCount = event.steps;
      _lastSavedDate = currentDate;
      _stepsToday = 0;
      _lastLocalSteps = 0;
      _localHourlyBuckets.clear();
      _healthHourlyBuckets.clear();
      _usingHealthData = false;

      await prefs.setInt('savedStepsCount', _savedStepsCount);
      await prefs.setString('lastSavedDate', _lastSavedDate);
      await prefs.setInt('lastKnownStepsToday', 0);
      await prefs.setInt('lastLocalSteps', 0);
      await prefs.setString('localHourlyBuckets', '{}');
      await prefs.setString('healthHourlyBuckets', '{}');
      await prefs.setBool('usingHealthData', false);
      await prefs.setDouble('realRunningTimeMin', 0.0);
      await prefs.setDouble('realRunningCalories', 0.0);
    }

    if (mounted) {
      setState(() {
        int currentLocalSteps = event.steps - _savedStepsCount;

        if (currentLocalSteps > _lastLocalSteps) {
          int deltaNovosPassos = currentLocalSteps - _lastLocalSteps;

          _localHourlyBuckets[currentHourKey] = (_localHourlyBuckets[currentHourKey] ?? 0) + deltaNovosPassos;
          _lastLocalSteps = currentLocalSteps;

          _stepsToday = _calculateTotalSteps();

          prefs.setInt('lastLocalSteps', _lastLocalSteps);
          prefs.setInt('lastKnownStepsToday', _stepsToday);
          prefs.setString('localHourlyBuckets', jsonEncode(_localHourlyBuckets));
        }
      });
    }
  }

  void _onStepCountError(error) {}

  String _getGreeting(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return l10n.goodMorning;
    } else if (hour < 18) {
      return l10n.goodAfternoon;
    } else {
      return l10n.goodEvening;
    }
  }

  Future<void> _startRun() async {
    final l10n = AppLocalizations.of(context)!;

    if (_isRunActive) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RunScreen()),
      );
      _checkForActiveRun();
    } else {
      final status = await Permission.location.request();
      if (status.isGranted) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RunScreen()),
        );
        _checkForActiveRun();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.locationPermissionRequired)),
        );
      }
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://matheussilvagarcia.com/projects/yara/privacypolicy/');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Não foi possível abrir o link da política de privacidade.');
    }
  }

  void _showPremiumDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).brightness == Brightness.dark ? Colors.grey[900]! : Colors.white,
                  Theme.of(context).brightness == Brightness.dark ? Colors.grey[850]! : Colors.blue[50]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.workspace_premium, color: Colors.amber, size: 72),
                const SizedBox(height: 16),
                Text(
                  l10n.unlockPremium,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.premiumDesc,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      PurchaseService().buyPremiumCharts();
                    },
                    child: Text(
                      PurchaseService().products.isNotEmpty
                          ? '${l10n.buyFor} ${PurchaseService().products.first.price}'
                          : l10n.buyNow,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.maybeLater, style: const TextStyle(color: Colors.grey)),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.language),
          content: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: localeNotifier.value?.languageCode ?? 'en',
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English (US)'),
                ),
                DropdownMenuItem(
                  value: 'pt',
                  child: Text('Português (Brasil)'),
                ),
              ],
              onChanged: (String? newValue) async {
                if (newValue != null) {
                  localeNotifier.value = Locale(newValue);
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('languageCode', newValue);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final String distance = (_stepsToday * 0.000762).toStringAsFixed(2);

    final String displayCalories = _usingHealthData && _realRunningCalories > 0
        ? _realRunningCalories.toStringAsFixed(0)
        : (_stepsToday * 0.04).toStringAsFixed(0);

    final String displayTime = _usingHealthData && _realRunningTimeMin > 0
        ? _realRunningTimeMin.toStringAsFixed(0)
        : (_stepsToday / 100).toStringAsFixed(0);

    final double activeRunCalories = _runDistance * 70.0;
    final int runMinutes = _runSeconds ~/ 60;
    final int runRemainingSeconds = _runSeconds % 60;
    final String activeRunTimeStr = '${runMinutes.toString().padLeft(2, '0')}:${runRemainingSeconds.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.bar_chart, color: Colors.amberAccent, size: 28),
                onPressed: () {
                  if (PurchaseService().isPremiumUser) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChartScreen()),
                    );
                  } else {
                    _showPremiumDialog();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DailyHistoryScreen()),
                  );
                },
              ),
              IconButton(
                icon: _isSyncing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.cloud_upload),
                onPressed: _isSyncing ? null : _manualSync,
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HistoryScreen()),
                  );
                },
              ),
              IconButton(
                icon: Icon(
                  Theme.of(context).brightness == Brightness.light
                      ? Icons.dark_mode
                      : Icons.light_mode,
                ),
                onPressed: () async {
                  final isDark = themeNotifier.value == ThemeMode.light;
                  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isDarkMode', isDark);
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                onSelected: (String value) {
                  if (value == 'privacy') {
                    _launchPrivacyPolicy();
                  } else if (value == 'credits') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreditsScreen()),
                    );
                  } else if (value == 'language') {
                    _showLanguageDialog();
                  } else if (value == 'delete_account') {
                    _deleteAccount();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'privacy',
                    child: Row(
                      children: [
                        const Icon(Icons.privacy_tip, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.privacyPolicy),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'credits',
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.credits),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'language',
                    child: Row(
                      children: [
                        const Icon(Icons.language, size: 20),
                        const SizedBox(width: 12),
                        Text(l10n.language),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'delete_account',
                    child: Row(
                      children: [
                        Icon(Icons.delete_forever, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Excluir Conta', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${_getGreeting(context)}, ${l10n.todayYouTook}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$_stepsToday',
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        l10n.steps,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildMetricItem(Icons.local_fire_department, displayCalories, 'kcal'),
                          _buildMetricItem(Icons.location_on, distance, 'km'),
                          _buildMetricItem(Icons.timer, displayTime, 'min'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 64,
                        child: ElevatedButton(
                          onPressed: _startRun,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRunActive
                                ? Colors.red.shade600
                                : Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isRunActive
                              ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Corrida em andamento',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$activeRunTimeStr  •  ${_runDistance.toStringAsFixed(2)} km  •  ${activeRunCalories.toStringAsFixed(0)} kcal',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.play_arrow, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                l10n.startRun,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 28,
                        child: OutlinedButton.icon(
                          onPressed: _syncWithHealthConnect,
                          icon: SvgPicture.asset(
                            'lib/assets/HealthConnect.svg',
                            width: 18,
                            height: 18,
                          ),
                          label: Text(
                            l10n.syncHealthConnect,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${l10n.lastSyncOn} $_lastSyncText',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String unit) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}