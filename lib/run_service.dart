import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'running_channel_id',
    'Running Tracker',
    description: 'Active run metrics',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'running_channel_id',
      initialNotificationTitle: 'Run in progress',
      initialNotificationContent: 'Starting...',
      foregroundServiceNotificationId: 1,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: false,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  int secondsElapsed = 0;
  double distanceKm = 0.0;
  List<Map<String, double>> route = [];

  final prefs = await SharedPreferences.getInstance();
  secondsElapsed = prefs.getInt('runSeconds') ?? 0;
  distanceKm = prefs.getDouble('runDistance') ?? 0.0;
  final routeString = prefs.getString('runRoute');
  if (routeString != null) {
    final List decoded = jsonDecode(routeString);
    route = decoded.map((p) => {'lat': p['lat'] as double, 'lng': p['lng'] as double}).toList();
  }

  late LocationSettings locationSettings;
  if (defaultTargetPlatform == TargetPlatform.android) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
      forceLocationManager: true,
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.high,
      activityType: ActivityType.fitness,
      distanceFilter: 5,
      pauseLocationUpdatesAutomatically: false,
      allowBackgroundLocationUpdates: true,
    );
  } else {
    locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  final positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
      .listen((Position position) {
    final newPoint = {'lat': position.latitude, 'lng': position.longitude};

    if (route.isNotEmpty) {
      final lastPoint = route.last;
      final distanceInMeters = Geolocator.distanceBetween(
        lastPoint['lat']!, lastPoint['lng']!,
        newPoint['lat']!, newPoint['lng']!,
      );
      distanceKm += distanceInMeters / 1000;
    }

    route.add(newPoint);
    prefs.setDouble('runDistance', distanceKm);
    prefs.setString('runRoute', jsonEncode(route));

    service.invoke('update', {
      'seconds': secondsElapsed,
      'distance': distanceKm,
      'lat': position.latitude,
      'lng': position.longitude,
    });
  });

  final timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
    secondsElapsed++;
    prefs.setInt('runSeconds', secondsElapsed);

    double pace = 0.0;
    if (distanceKm > 0) {
      pace = (secondsElapsed / 60) / distanceKm;
    }

    final int minutes = secondsElapsed ~/ 60;
    final int remainingSeconds = secondsElapsed % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';

    int pMinutes = pace.floor();
    int pSeconds = ((pace - pMinutes) * 60).floor();
    String paceStr = pace > 0 ? '$pMinutes:${pSeconds.toString().padLeft(2, '0')}' : '0:00';

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        flutterLocalNotificationsPlugin.show(
          id: 1,
          title: 'Run in progress',
          body: 'Time: $timeStr  |  Dist: ${distanceKm.toStringAsFixed(2)} km  |  Pace: $paceStr/km',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'running_channel_id',
              'Running Tracker',
              icon: 'ic_notification',
              ongoing: true,
              importance: Importance.low,
              priority: Priority.low,
            ),
          ),
        );
      }
    }

    service.invoke('update', {
      'seconds': secondsElapsed,
      'distance': distanceKm,
    });
  });

  service.on('stopService').listen((event) {
    timer.cancel();
    positionStream.cancel();
    service.stopSelf();
  });
}