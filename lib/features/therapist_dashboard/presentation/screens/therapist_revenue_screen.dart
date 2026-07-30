import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class TherapistRevenueScreen extends StatelessWidget {
  const TherapistRevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revenue & Earnings Analytics')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const GlassContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Earnings (July 2026)',
                        style: TextStyle(
                            color: AppColors.textSecondaryLight, fontSize: 13)),
                    SizedBox(height: 6),
                    Text('\$4,850.00',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryPurple)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.arrow_upward_rounded,
                            color: AppColors.moodEcstatic, size: 18),
                        Text(' +18.4% from last month',
                            style: TextStyle(
                                color: AppColors.moodEcstatic,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text('Weekly Revenue Breakdown',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GlassContainer(
                height: 220,
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            const weeks = [
                              'Week 1',
                              'Week 2',
                              'Week 3',
                              'Week 4'
                            ];
                            if (val.toInt() >= 0 &&
                                val.toInt() < weeks.length) {
                              return Text(weeks[val.toInt()],
                                  style: const TextStyle(fontSize: 12));
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      BarChartGroupData(x: 0, barRods: [
                        BarChartRodData(
                            toY: 980,
                            color: AppColors.primaryPurple,
                            width: 18,
                            borderRadius: BorderRadius.circular(6))
                      ]),
                      BarChartGroupData(x: 1, barRods: [
                        BarChartRodData(
                            toY: 1240,
                            color: AppColors.primaryPurple,
                            width: 18,
                            borderRadius: BorderRadius.circular(6))
                      ]),
                      BarChartGroupData(x: 2, barRods: [
                        BarChartRodData(
                            toY: 1100,
                            color: AppColors.primaryPurple,
                            width: 18,
                            borderRadius: BorderRadius.circular(6))
                      ]),
                      BarChartGroupData(x: 3, barRods: [
                        BarChartRodData(
                            toY: 1530,
                            color: AppColors.primaryPurple,
                            width: 18,
                            borderRadius: BorderRadius.circular(6))
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
