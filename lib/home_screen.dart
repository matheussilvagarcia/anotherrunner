import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:health/health.dart';
import 'auth_service.dart';
import 'run_screen.dart';
import 'history_screen.dart';
import 'daily_history_screen.dart';
import 'main.dart';

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
    if (await Permission.activityRecognition.request().isGranted) {
      final prefs = await SharedPreferences.getInstance();
      _savedStepsCount = prefs.getInt('savedStepsCount') ?? 0;
      _lastSavedDate = prefs.getString('lastSavedDate') ?? '';
      _stepsToday = prefs.getInt('lastKnownStepsToday') ?? 0;

      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    }
  }

  Future<void> _syncWithHealthConnect() async {
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
            _stepsToday = steps;
            _realRunningTimeMin = tempRunningTime;
            _realRunningCalories = tempRunningCalories;
            _usingHealthData = true;
          });

          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt('lastKnownStepsToday', _stepsToday);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data synced! Runs added to history.')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No health data found for today.')),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission denied to access Health data.')),
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
    await _syncToCloud();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data synced to cloud successfully!')),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  Future<void> _startRun() async {
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
        const SnackBar(content: Text('Location permission is required to track your run.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String distance = (_stepsToday * 0.000762).toStringAsFixed(2);

    final String displayCalories = _usingHealthData && _realRunningCalories > 0
        ? _realRunningCalories.toStringAsFixed(0)
        : (_stepsToday * 0.04).toStringAsFixed(0);

    final String displayTime = _usingHealthData && _realRunningTimeMin > 0
        ? _realRunningTimeMin.toStringAsFixed(0)
        : (_stepsToday / 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
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
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${_getGreeting()}, today you took:',
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
              const Text(
                'STEPS',
                style: TextStyle(
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
                  label: const Text(
                    'Start Run',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  icon: const Icon(Icons.health_and_safety, size: 18, color: Colors.green),
                  label: const Text(
                    'Sync Health Connect',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                'Last cloud sync on $_lastSyncText',
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