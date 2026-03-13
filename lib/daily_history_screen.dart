import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:anotherrunner/l10n/app_localizations.dart'; // Importação das traduções

class DailyHistoryScreen extends StatelessWidget {
  const DailyHistoryScreen({super.key});

  String _formatDateString(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        return '${parts[2]}/${parts[1]}/${parts[0]}';
      }
    } catch (e) {
      // Ignorar e retornar o original se falhar
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!; // Acesso às traduções

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyActivity),
      ),
      body: user == null
          ? Center(child: Text(l10n.authenticationRequired)) // Reutilizando a variável já existente
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('daily_stats')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                l10n.noDailyRecords,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final records = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index].data() as Map<String, dynamic>;

              final dateStr = record['date'] as String? ?? l10n.unknownDate; // Substituído Unknown
              final steps = record['steps'] as int? ?? 0;
              final distance = record['distanceKm'] as double? ?? 0.0;
              final calories = record['calories'] as double? ?? 0.0;
              final time = record['timeMin'] as double? ?? 0.0;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDateString(dateStr),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                          const Icon(Icons.directions_walk, color: Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            steps.toString(),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0, left: 8.0),
                            child: Text(
                              l10n.steps, // Reutilizando a chave "STEPS" original do seu app_en.arb
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniMetric(Icons.local_fire_department, '${calories.toStringAsFixed(0)} kcal'),
                          _buildMiniMetric(Icons.location_on, '${distance.toStringAsFixed(2)} km'),
                          _buildMiniMetric(Icons.timer, '${time.toStringAsFixed(0)} min'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
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