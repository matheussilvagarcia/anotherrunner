import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:anotherrunner/l10n/app_localizations.dart';

class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  StreamSubscription<Map<String, dynamic>?>? _serviceSubscription;
  Timer? _localTimer;

  List<LatLng> _route = [];
  final Set<Polyline> _polylines = {};

  bool _isRunning = false;
  int _secondsElapsed = 0;
  double _distanceKm = 0.0;
  double _pace = 0.0;

  LatLng? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _locateUser();
    _recoverRunState();
    _listenToService();
  }

  void _listenToService() {
    _serviceSubscription = FlutterBackgroundService().on('update').listen((event) {
      if (event == null) return;
      if (!mounted) return;

      setState(() {
        if (event.containsKey('seconds')) {
          int bgSeconds = (event['seconds'] as num).toInt();
          if ((_secondsElapsed - bgSeconds).abs() > 2) {
            _secondsElapsed = bgSeconds;
          }
        }
        if (event.containsKey('distance')) {
          _distanceKm = (event['distance'] as num).toDouble();
          if (_distanceKm > 0 && _secondsElapsed > 0) {
            _pace = (_secondsElapsed / 60) / _distanceKm;
          }
        }
        if (event.containsKey('lat') && event.containsKey('lng')) {
          final newLatLng = LatLng(
              (event['lat'] as num).toDouble(),
              (event['lng'] as num).toDouble()
          );
          _route.add(newLatLng);
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: _route,
              color: Colors.blue,
              width: 5,
            ),
          );
          _moveCamera(newLatLng);
        }
      });
    });
  }

  Future<void> _recoverRunState() async {
    final prefs = await SharedPreferences.getInstance();
    final isActive = prefs.getBool('isRunActive') ?? false;

    setState(() {
      _secondsElapsed = prefs.getInt('runSeconds') ?? 0;
      _distanceKm = prefs.getDouble('runDistance') ?? 0.0;
      if (_distanceKm > 0 && _secondsElapsed > 0) {
        _pace = (_secondsElapsed / 60) / _distanceKm;
      }

      final routeString = prefs.getString('runRoute');
      if (routeString != null) {
        final List decoded = jsonDecode(routeString);
        _route = decoded.map((p) => LatLng((p['lat'] as num).toDouble(), (p['lng'] as num).toDouble())).toList();
        if (_route.isNotEmpty) {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: _route,
              color: Colors.blue,
              width: 5,
            ),
          );
        }
      }
    });

    if (isActive) {
      final isRunningInBg = await FlutterBackgroundService().isRunning();

      if (isRunningInBg) {
        setState(() {
          _isRunning = true;
        });

        _localTimer?.cancel();
        _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (mounted) {
            setState(() {
              _secondsElapsed++;
              if (_distanceKm > 0) {
                _pace = (_secondsElapsed / 60) / _distanceKm;
              }
            });
          }
        });
      } else {
        setState(() {
          _isRunning = false;
        });
      }
    }
  }

  Future<void> _clearRunState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isRunActive', false);
    await prefs.remove('runSeconds');
    await prefs.remove('runDistance');
    await prefs.remove('runRoute');
  }

  Future<void> _locateUser() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
    }
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

    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('isRunActive', true);
    });

    _localTimer?.cancel();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _secondsElapsed++;
          if (_distanceKm > 0) {
            _pace = (_secondsElapsed / 60) / _distanceKm;
          }
        });
      }
    });

    FlutterBackgroundService().startService();
  }

  void _pauseRun() {
    setState(() {
      _isRunning = false;
    });

    _localTimer?.cancel();
    FlutterBackgroundService().invoke('stopService');
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

    await _clearRunState();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    _serviceSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.currentRun),
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
                    _buildRunMetric(l10n.timeLabel, _formatTime(_secondsElapsed)),
                    _buildRunMetric(l10n.paceLabel, '${_formatPace(_pace)} /km'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRunMetric(l10n.distanceLabel, '${_distanceKm.toStringAsFixed(2)} km'),
                    _buildRunMetric(l10n.caloriesLabel, '${(_distanceKm * 70).toStringAsFixed(0)} kcal'),
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