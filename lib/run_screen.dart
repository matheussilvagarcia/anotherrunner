import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  StreamSubscription<Position>? _positionStream;
  Timer? _timer;

  List<LatLng> _route = [];
  Set<Polyline> _polylines = {};

  bool _isRunning = false;
  int _secondsElapsed = 0;
  double _distanceKm = 0.0;
  double _pace = 0.0;

  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _locateUser();
  }

  Future<void> _initNotifications() async {
    await Permission.notification.request();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('ic_notification');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> _showOngoingNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'running_channel_id',
      'Running Tracker',
      channelDescription: 'Active run metrics',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
    );

    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);

    final String time = _formatTime(_secondsElapsed);
    final String dist = _distanceKm.toStringAsFixed(2);
    final String paceStr = _formatPace(_pace);

    await _notificationsPlugin.show(
      id: 0,
      title: 'Run in progress',
      body: 'Time: $time  |  Dist: $dist km  |  Pace: $paceStr/km',
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> _cancelNotification() async {
    await _notificationsPlugin.cancel(id: 0);
  }

  Future<void> _locateUser() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });
  }

  void _toggleRun() {
    if (_isRunning) {
      _pauseRun();
    } else {
      _startRun();
    }
  }

  void _startRun() {
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsElapsed++;
        if (_distanceKm > 0) {
          _pace = (_secondsElapsed / 60) / _distanceKm;
        }
      });
      _showOngoingNotification();
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((Position position) {
      final newLatLng = LatLng(position.latitude, position.longitude);

      if (_route.isNotEmpty) {
        final lastLatLng = _route.last;
        final distanceInMeters = Geolocator.distanceBetween(
          lastLatLng.latitude,
          lastLatLng.longitude,
          newLatLng.latitude,
          newLatLng.longitude,
        );
        setState(() {
          _distanceKm += distanceInMeters / 1000;
        });
      }

      setState(() {
        _route.add(newLatLng);
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: _route,
            color: Colors.blue,
            width: 5,
          ),
        );
      });

      _moveCamera(newLatLng);
    });
  }

  void _pauseRun() {
    setState(() {
      _isRunning = false;
    });
    _timer?.cancel();
    _positionStream?.pause();
    _cancelNotification();
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLng(position));
  }

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatPace(double pace) {
    if (pace <= 0 || !pace.isFinite) return '0:00';
    final int minutes = pace.floor();
    final int seconds = ((pace - minutes) * 60).floor();
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _finishRun() async {
    _pauseRun();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final calories = _distanceKm * 70.0;

      final runData = {
        'timestamp': FieldValue.serverTimestamp(),
        'durationSeconds': _secondsElapsed,
        'distanceKm': _distanceKm,
        'averagePace': _pace,
        'calories': calories,
        'route': _route.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('runs')
          .add(runData);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionStream?.cancel();
    _cancelNotification();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Current Run'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 16.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRunMetric('TIME', _formatTime(_secondsElapsed)),
                    _buildRunMetric('PACE', '${_formatPace(_pace)} /km'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRunMetric('DISTANCE', '${_distanceKm.toStringAsFixed(2)} km'),
                    _buildRunMetric('CALORIES', '${(_distanceKm * 70).toStringAsFixed(0)} kcal'),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.large(
                      heroTag: 'play_pause',
                      onPressed: _toggleRun,
                      backgroundColor: _isRunning ? Colors.orange : Colors.blue,
                      child: Icon(
                        _isRunning ? Icons.pause : Icons.play_arrow,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    if (_secondsElapsed > 0 && !_isRunning) ...[
                      const SizedBox(width: 24),
                      FloatingActionButton.large(
                        heroTag: 'stop',
                        onPressed: _finishRun,
                        backgroundColor: Colors.red,
                        child: const Icon(
                          Icons.stop,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRunMetric(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}