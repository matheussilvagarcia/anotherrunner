import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStaticMapUrl(List<dynamic> routeData) {
    if (routeData.isEmpty) return '';

    List<LatLng> points = routeData.map((p) => LatLng(p['lat'], p['lng'])).toList();
    String pathString = 'weight:5|color:0x0000ffff|enc:';
    pathString += _encodePolyline(points);

    final apiKey = dotenv.env['MAPS_API_KEY'] ?? '';
    return 'https://maps.googleapis.com/maps/api/staticmap?size=600x300&scale=2&maptype=roadmap&path=$pathString&key=$apiKey';
  }

  String _encodePolyline(List<LatLng> points) {
    StringBuffer varString = StringBuffer();
    int lLastLat = 0;
    int lLastLng = 0;

    for (LatLng point in points) {
      int lLat = (point.latitude * 1e5).round();
      int lLng = (point.longitude * 1e5).round();

      _encodeValue(lLat - lLastLat, varString);
      _encodeValue(lLng - lLastLng, varString);

      lLastLat = lLat;
      lLastLng = lLng;
    }
    return varString.toString();
  }

  void _encodeValue(int value, StringBuffer varString) {
    value = value < 0 ? ~(value << 1) : (value << 1);
    while (value >= 0x20) {
      varString.write(String.fromCharCode((0x20 | (value & 0x1f)) + 63));
      value >>= 5;
    }
    varString.write(String.fromCharCode(value + 63));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Run History'),
      ),
      body: user == null
          ? const Center(child: Text('Authentication required'))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('runs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No runs recorded yet.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final runs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: runs.length,
            itemBuilder: (context, index) {
              final run = runs[index].data() as Map<String, dynamic>;

              final timestamp = run['timestamp'] as Timestamp?;
              final date = timestamp != null ? timestamp.toDate() : DateTime.now();
              final distance = run['distanceKm'] as double? ?? 0.0;
              final duration = run['durationSeconds'] as int? ?? 0;
              final pace = run['averagePace'] as double? ?? 0.0;
              final calories = run['calories'] as double? ?? (distance * 70.0);
              final route = run['route'] as List<dynamic>? ?? [];
              final source = run['source'] as String? ?? 'app';

              final formattedDate = _formatDate(date);
              final formattedDistance = distance.toStringAsFixed(2);
              final mapUrl = _getStaticMapUrl(route);

              return RunHistoryCard(
                formattedDate: formattedDate,
                formattedDistance: formattedDistance,
                mapUrl: mapUrl,
                durationSeconds: duration,
                pace: pace,
                calories: calories,
                source: source,
              );
            },
          );
        },
      ),
    );
  }
}

class RunHistoryCard extends StatefulWidget {
  final String formattedDate;
  final String formattedDistance;
  final String mapUrl;
  final int durationSeconds;
  final double pace;
  final double calories;
  final String source;

  const RunHistoryCard({
    super.key,
    required this.formattedDate,
    required this.formattedDistance,
    required this.mapUrl,
    required this.durationSeconds,
    required this.pace,
    required this.calories,
    required this.source,
  });

  @override
  State<RunHistoryCard> createState() => _RunHistoryCardState();
}

class _RunHistoryCardState extends State<RunHistoryCard> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

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

  Future<void> _shareRunCard() async {
    setState(() {
      _isSharing = true;
    });

    try {
      final imageBytes = await _screenshotController.capture(
        delay: const Duration(milliseconds: 10),
      );

      if (imageBytes != null) {
        final directory = await getTemporaryDirectory();
        final imagePath = await File('${directory.path}/shared_run_${DateTime.now().millisecondsSinceEpoch}.png').create();
        await imagePath.writeAsBytes(imageBytes);

        final XFile xFile = XFile(imagePath.path);
        await Share.shareXFiles(
          [xFile],
          text: 'Check out my run on AnotherRunner on ${widget.formattedDate}!',
        );
      }
    } catch (e) {
      debugPrint('Error sharing card: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Card(
        elevation: 2,
        color: Theme.of(context).cardColor,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.formattedDate,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_isSharing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.share, size: 20, color: Colors.blue),
                      onPressed: _shareRunCard,
                    ),
                ],
              ),
              if (widget.source == 'health_connect')
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: const [
                      Icon(Icons.health_and_safety, size: 16, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Captured by Health Connect',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              if (widget.mapUrl.isNotEmpty)
                Container(
                  height: 150,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.mapUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.map_outlined, color: Colors.grey, size: 40),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              Text(
                '${widget.formattedDistance} km',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniMetric(Icons.timer, _formatTime(widget.durationSeconds)),
                  _buildMiniMetric(Icons.speed, '${_formatPace(widget.pace)} /km'),
                  _buildMiniMetric(Icons.local_fire_department, '${widget.calories.toStringAsFixed(0)} kcal'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}