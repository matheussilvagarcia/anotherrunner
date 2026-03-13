import 'dart:math';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health/health.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'auth_service.dart';
import 'run_screen.dart';
import 'history_screen.dart';
import 'daily_history_screen.dart';
import 'chart_screen.dart';
import 'main.dart';
import 'purchase_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Stream<StepCount> _stepCountStream;
  int _stepsToday = 0;
  int _savedStepsCount = 0;
  String _lastSavedDate = '';

  String _lastSyncText = 'Never';
  bool _isSyncing = false;

  double _realRunningTimeMin = 0.0;
  double _realRunningCalories = 0.0;
  bool _usingHealthData = false;

  @override
  void initState() {
    super.initState();
    _initPedometer();
    _loadLastSyncAndAutoSync();
    _checkForActiveRun();
  }

  Future<void> _checkForActiveRun() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunActive = prefs.getBool('isRunActive') ?? false;

    if (isRunActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RunScreen()),
        );
      });
    }
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

  Future<void> _initPedometer() async {
    final prefs = await SharedPreferences.getInstance();
    _savedStepsCount = prefs.getInt('savedStepsCount') ?? 0;
    _lastSavedDate = prefs.getString('lastSavedDate') ?? '';
    _stepsToday = prefs.getInt('lastKnownStepsToday') ?? 0;

    _realRunningTimeMin = prefs.getDouble('realRunningTimeMin') ?? 0.0;
    _realRunningCalories = prefs.getDouble('realRunningCalories') ?? 0.0;
    _usingHealthData = prefs.getBool('usingHealthData') ?? false;

    final currentDate = DateTime.now().toString().substring(0, 10);
    if (_lastSavedDate.isNotEmpty && _lastSavedDate != currentDate) {
      _usingHealthData = false;
      _realRunningTimeMin = 0.0;
      _realRunningCalories = 0.0;
      _stepsToday = 0;
      await prefs.setBool('usingHealthData', false);
      await prefs.setDouble('realRunningTimeMin', 0.0);
      await prefs.setDouble('realRunningCalories', 0.0);
      await prefs.setInt('lastKnownStepsToday', 0);
    }

    if (mounted) {
      setState(() {});
    }

    if (await Permission.activityRecognition.request().isGranted) {
      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    }
  }

  Future<void> _syncWithHealthConnect() async {
    final l10n = AppLocalizations.of(context)!;
    final types = [
      HealthDataType.STEPS,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WORKOUT,
    ];

    try {
      Health().configure();

      bool authorized = await Health().requestAuthorization(types);

      if (authorized) {
        final now = DateTime.now();
        final midnight = DateTime(now.year, now.month, now.day);

        int? steps = await Health().getTotalStepsInInterval(midnight, now);

        List<HealthDataPoint> workoutData = await Health().getHealthDataFromTypes(
          types: [HealthDataType.WORKOUT],
          startTime: midnight,
          endTime: now,
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

              tempRunningTime += (durationMillis / 1000) / 60;
              tempRunningCalories += calories;

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
                  'distanceKm': 0.0,
                  'averagePace': 0.0,
                  'calories': calories,
                  'route': [],
                  'source': 'health_connect',
                }, SetOptions(merge: true));
              }
            }
          }
        }

        if (steps != null && steps > 0) {
          setState(() {
            _stepsToday = max(_stepsToday, steps);
            _realRunningTimeMin = tempRunningTime;
            _realRunningCalories = tempRunningCalories;
            _usingHealthData = true;
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('lastKnownStepsToday', _stepsToday);
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
              SnackBar(content: Text(l10n.hcNoData)),
            );
          }
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
    } catch (e) {
      debugPrint('Sync historical error: $e');
    }
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
      } catch (e) {
        debugPrint('Sync error: $e');
      }
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

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final currentDate = DateTime.now().toString().substring(0, 10);

    if (event.steps < _savedStepsCount) {
      _savedStepsCount = 0;
      await prefs.setInt('savedStepsCount', _savedStepsCount);
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
      _usingHealthData = false;

      await prefs.setInt('savedStepsCount', _savedStepsCount);
      await prefs.setString('lastSavedDate', _lastSavedDate);
      await prefs.setInt('lastKnownStepsToday', 0);
      await prefs.setBool('usingHealthData', false);
      await prefs.setDouble('realRunningTimeMin', 0.0);
      await prefs.setDouble('realRunningCalories', 0.0);
    }

    if (mounted && !_usingHealthData) {
      setState(() {
        _stepsToday = event.steps - _savedStepsCount;
        prefs.setInt('lastKnownStepsToday', _stepsToday);
      });
    }
  }

  void _onStepCountError(error) {
    if (mounted && !_usingHealthData) {
      setState(() {
        _stepsToday = 0;
      });
    }
  }

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
    final status = await Permission.location.request();
    if (status.isGranted) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RunScreen()),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationPermissionRequired)),
      );
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
                onPressed: () => AuthService().signOut(),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (String value) {
                  if (value == 'privacy') {
                  } else if (value == 'credits') {
                  } else if (value == 'language') {
                    _showLanguageDialog();
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'privacy',
                    child: Text(l10n.privacyPolicy),
                  ),
                  PopupMenuItem<String>(
                    value: 'credits',
                    child: Text(l10n.credits),
                  ),
                  PopupMenuItem<String>(
                    value: 'language',
                    child: Text(l10n.language),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              const SizedBox(height: 24),
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
              const SizedBox(height: 64),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMetricItem(Icons.local_fire_department, displayCalories, 'kcal'),
                  _buildMetricItem(Icons.location_on, distance, 'km'),
                  _buildMetricItem(Icons.timer, displayTime, 'min'),
                ],
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _startRun,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  label: Text(
                    l10n.startRun,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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