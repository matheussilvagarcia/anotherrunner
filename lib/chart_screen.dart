import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:anotherrunner/l10n/app_localizations.dart'; // Importação das traduções

class ChartScreen extends StatefulWidget {
  const ChartScreen({super.key});

  @override
  State<ChartScreen> createState() => _ChartScreenState();
}

class _ChartScreenState extends State<ChartScreen> {
  bool _isWeekly = true;
  bool _isLoading = true;
  List<Map<String, dynamic>> _rawData = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('daily_stats')
          .get();

      final data = snapshot.docs.map((doc) {
        final d = doc.data();
        return {
          'date': DateTime.parse(d['date']),
          'steps': d['steps'] ?? 0,
          'calories': (d['calories'] ?? 0.0).toDouble(),
          'distanceKm': (d['distanceKm'] ?? 0.0).toDouble(),
          'timeMin': (d['timeMin'] ?? 0.0).toDouble(),
        };
      }).toList();

      data.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

      setState(() {
        _rawData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _processWeeklyData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> last7Days = [];
    for (int i = 6; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final record = _rawData.firstWhere(
            (e) {
          final d = e['date'] as DateTime;
          return d.year == targetDate.year && d.month == targetDate.month && d.day == targetDate.day;
        },
        orElse: () => {
          'date': targetDate,
          'steps': 0,
          'calories': 0.0,
          'distanceKm': 0.0,
          'timeMin': 0.0,
        },
      );
      last7Days.add(record);
    }
    return last7Days;
  }

  List<Map<String, dynamic>> _processMonthlyData() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> last6Months = [];

    for (int i = 5; i >= 0; i--) {
      int targetMonth = now.month - i;
      int targetYear = now.year;
      if (targetMonth <= 0) {
        targetMonth += 12;
        targetYear -= 1;
      }

      final monthRecords = _rawData.where((e) {
        final d = e['date'] as DateTime;
        return d.year == targetYear && d.month == targetMonth;
      }).toList();

      int sumSteps = 0;
      double sumCal = 0.0;
      double sumDist = 0.0;
      double sumTime = 0.0;

      for (var r in monthRecords) {
        sumSteps += r['steps'] as int;
        sumCal += r['calories'] as double;
        sumDist += r['distanceKm'] as double;
        sumTime += r['timeMin'] as double;
      }

      int count = monthRecords.isEmpty ? 1 : monthRecords.length;

      last6Months.add({
        'label': '$targetMonth/$targetYear',
        'steps': (sumSteps / count).round(),
        'calories': sumCal / count,
        'distanceKm': sumDist / count,
        'timeMin': sumTime / count,
      });
    }
    return last6Months;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Inicializando o tradutor

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.activityAverages), // Traduzido
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l10n.last7Days)), // Traduzido
                ButtonSegment(value: false, label: Text(l10n.monthlyAverages)), // Traduzido
              ],
              selected: {_isWeekly},
              onSelectionChanged: (Set<bool> newSelection) {
                setState(() {
                  _isWeekly = newSelection.first;
                });
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildChartCard(l10n.chartSteps, 'steps', Colors.blue), // Traduzido
                _buildChartCard(l10n.chartCalories, 'calories', Colors.orange), // Traduzido
                _buildChartCard(l10n.chartDistance, 'distanceKm', Colors.green), // Traduzido
                _buildChartCard(l10n.chartDuration, 'timeMin', Colors.purple), // Traduzido
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, String dataKey, Color color) {
    final weeklyData = _isWeekly ? _processWeeklyData() : [];
    final monthlyData = !_isWeekly ? _processMonthlyData() : [];

    final length = _isWeekly ? weeklyData.length : monthlyData.length;
    double maxY = 0;

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < length; i++) {
      double value = 0;
      if (_isWeekly) {
        final val = weeklyData[i][dataKey];
        value = val is int ? val.toDouble() : val as double;
      } else {
        final val = monthlyData[i][dataKey];
        value = val is int ? val.toDouble() : val as double;
      }

      if (value > maxY) maxY = value;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: value,
              color: color,
              width: 16,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    if (maxY == 0) maxY = 10;

    return Card(
      margin: const EdgeInsets.only(bottom: 24.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 || value.toInt() >= length) return const SizedBox.shrink();
                          String text = '';
                          if (_isWeekly) {
                            final d = weeklyData[value.toInt()]['date'] as DateTime;
                            text = '${d.day}/${d.month}';
                          } else {
                            text = monthlyData[value.toInt()]['label'] as String;
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(text, style: const TextStyle(fontSize: 10)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const SizedBox.shrink();
                          return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: barGroups,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}