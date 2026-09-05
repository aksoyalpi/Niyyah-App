import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocklist/data/native_bridge.dart';

class StatsCard extends StatelessWidget {
  final List<DayStats> days;

  const StatsCard({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final today = days.isNotEmpty ? days.first : null;
    final maxMinutes = days.fold<int>(0, (m, d) => m > d.minutes ? m : d.minutes);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${today?.minutes ?? 0}',
                        style: const TextStyle(
                          fontSize: 40,
                          height: 1.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'minutes read today',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${today?.items ?? 0}',
                        style: const TextStyle(
                          fontSize: 40,
                          height: 1.0,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'verses & hadiths today',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  maxY: (maxMinutes + 5).toDouble(),
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    for (var i = 0; i < days.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: days[i].minutes.toDouble(),
                            width: 16,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                            color: i == 0
                                ? AppColors.accent
                                : AppColors.accentSoft,
                          ),
                        ],
                      ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 20,
                        getTitlesWidget: (value, meta) =>
                            _weekdayLabel(days[value.toInt()].date),
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weekdayLabel(String date) {
    final parts = date.split('-');
    if (parts.length != 3) return const SizedBox.shrink();
    final weekday =
        DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])).weekday;
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Text(
      labels[weekday - 1],
      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
    );
  }
}
