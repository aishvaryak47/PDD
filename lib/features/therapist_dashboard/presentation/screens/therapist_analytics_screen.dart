import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class TherapistAnalyticsScreen extends StatelessWidget {
  const TherapistAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice Analytics & Outcomes 📊',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Fresh baseline metrics • Track real-time patient recovery as sessions are logged',
                    style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fresh Zero Overview Cards
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildMetricTile('Avg Recovery Rate', '0.0%', 'Baseline start', AppColors.moodEcstatic),
                  _buildMetricTile('Sessions Completed', '0', 'Ready for intake', AppColors.primaryPurple),
                  _buildMetricTile('High Risk Cases', '0', 'Clean radar', AppColors.accentCoral),
                  _buildMetricTile('Attendance Rate', '100%', 'Initial baseline', AppColors.accentTeal),
                ],
              ),
              const SizedBox(height: 24),

              // Recovery & Mood Chart - Fresh Zero Baseline
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Client Recovery Baseline Curve', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Starts at 0.0 • Progress renders automatically as SOAP notes & logs are added', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: true, drawVerticalLine: false),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const w = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7', 'W8'];
                                  if (val.toInt() >= 0 && val.toInt() < w.length) {
                                    return Text(w[val.toInt()], style: const TextStyle(fontSize: 11));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 0.0),
                                FlSpot(1, 0.0),
                                FlSpot(2, 0.0),
                                FlSpot(3, 0.0),
                                FlSpot(4, 0.0),
                                FlSpot(5, 0.0),
                                FlSpot(6, 0.0),
                                FlSpot(7, 0.0),
                              ],
                              isCurved: true,
                              color: AppColors.primaryPurple,
                              barWidth: 3,
                              belowBarData: BarAreaData(show: true, color: AppColors.primaryPurple.withValues(alpha: 0.1)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Diagnostic Caseload Bar Chart - Fresh Zero Baseline
              GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Diagnostic Caseload Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 180,
                      child: BarChart(
                        BarChartData(
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          titlesData: FlTitlesData(
                            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (val, meta) {
                                  const cats = ['GAD', 'MDD', 'PTSD', 'Panic', 'Other'];
                                  if (val.toInt() >= 0 && val.toInt() < cats.length) {
                                    return Text(cats[val.toInt()], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold));
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                          ),
                          barGroups: [
                            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 0, color: AppColors.primaryPurple, width: 22, borderRadius: BorderRadius.circular(6))]),
                            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 0, color: AppColors.accentTeal, width: 22, borderRadius: BorderRadius.circular(6))]),
                            BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 0, color: AppColors.accentCoral, width: 22, borderRadius: BorderRadius.circular(6))]),
                            BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 0, color: Colors.blue, width: 22, borderRadius: BorderRadius.circular(6))]),
                            BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 0, color: Colors.amber, width: 22, borderRadius: BorderRadius.circular(6))]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile(String title, String val, String sub, Color col) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: col.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
          const SizedBox(height: 6),
          Text(val, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: col)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
