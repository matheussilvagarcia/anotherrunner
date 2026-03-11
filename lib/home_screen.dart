import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import 'run_screen.dart';
import 'history_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  Future<void> _initPedometer() async {
    if (await Permission.activityRecognition.request().isGranted) {
      final prefs = await SharedPreferences.getInstance();
      _savedStepsCount = prefs.getInt('savedStepsCount') ?? 0;
      _lastSavedDate = prefs.getString('lastSavedDate') ?? '';

      _stepCountStream = Pedometer.stepCountStream;
      _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
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
      _savedStepsCount = event.steps;
      _lastSavedDate = currentDate;
      await prefs.setInt('savedStepsCount', _savedStepsCount);
      await prefs.setString('lastSavedDate', _lastSavedDate);
    }

    if (mounted) {
      setState(() {
        _stepsToday = event.steps - _savedStepsCount;
      });
    }
  }

  void _onStepCountError(error) {
    if (mounted) {
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
    final String calories = (_stepsToday * 0.04).toStringAsFixed(0);
    final String time = (_stepsToday / 100).toStringAsFixed(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
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
                  _buildMetricItem(Icons.local_fire_department, calories, 'kcal'),
                  _buildMetricItem(Icons.location_on, distance, 'km'),
                  _buildMetricItem(Icons.timer, time, 'min'),
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