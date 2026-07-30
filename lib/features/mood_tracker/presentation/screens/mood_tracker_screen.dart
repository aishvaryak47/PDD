import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/psynova_sync_service.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen> {
  double _selectedMood = 4.0;
  final Set<String> _selectedEmotions = {'Calm', 'Grateful'};
  List<Map<String, dynamic>> _savedMoodLogs = [];

  final List<String> _allEmotions = [
    'Calm',
    'Grateful',
    'Anxious',
    'Energetic',
    'Overwhelmed',
    'Hopeful',
    'Tired',
    'Focused'
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final loaded = await PsynovaSyncService.loadMoodLogs();
    if (mounted) {
      setState(() {
        _savedMoodLogs = loaded;
      });
    }
  }

  String _getMoodLabel(double val) {
    if (val >= 4.5) return 'Ecstatic 😄';
    if (val >= 3.5) return 'Happy 😊';
    if (val >= 2.5) return 'Neutral 😐';
    if (val >= 1.5) return 'Sad 😔';
    return 'Anxious 😰';
  }

  Color _getMoodColor(double val) {
    if (val >= 4.5) return AppColors.moodEcstatic;
    if (val >= 3.5) return AppColors.moodHappy;
    if (val >= 2.5) return AppColors.moodNeutral;
    if (val >= 1.5) return AppColors.moodSad;
    return AppColors.moodAnxious;
  }

  List<FlSpot> _buildChartSpots() {
    if (_savedMoodLogs.isEmpty) {
      return const [
        FlSpot(0, 3.0),
        FlSpot(1, 4.0),
        FlSpot(2, 3.5),
        FlSpot(3, 4.5),
        FlSpot(4, 4.0),
        FlSpot(5, 4.8),
        FlSpot(6, 4.0),
      ];
    }
    final spots = <FlSpot>[];
    final count = _savedMoodLogs.length;
    final startIndex = count > 7 ? count - 7 : 0;
    int spotX = 0;

    for (int i = startIndex; i < count; i++) {
      final val = (_savedMoodLogs[i]['score'] as num?)?.toDouble() ?? 3.0;
      spots.add(FlSpot(spotX.toDouble(), val));
      spotX++;
    }

    while (spots.length < 7) {
      spots.insert(0, const FlSpot(0, 3.0));
      for (int k = 0; k < spots.length; k++) {
        spots[k] = FlSpot(k.toDouble(), spots[k].y);
      }
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Mood Analyzer')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Interactive Check-in Card
              GlassContainer(
                child: Column(
                  children: [
                    Text(
                      _getMoodLabel(_selectedMood),
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _getMoodColor(_selectedMood)),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _selectedMood,
                      min: 1.0,
                      max: 5.0,
                      divisions: 4,
                      activeColor: _getMoodColor(_selectedMood),
                      onChanged: (val) => setState(() => _selectedMood = val),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select Emotion Tags:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allEmotions.map((emotion) {
                        final isSelected = _selectedEmotions.contains(emotion);
                        return FilterChip(
                          label: Text(emotion),
                          selected: isSelected,
                          selectedColor:
                              AppColors.primaryIndigo.withValues(alpha: 0.2),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedEmotions.add(emotion);
                              } else {
                                _selectedEmotions.remove(emotion);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Log Today\'s Mood',
                      onPressed: () async {
                        final entry = {
                          'id': 'mood-${DateTime.now().millisecondsSinceEpoch}',
                          'score': _selectedMood,
                          'label': _getMoodLabel(_selectedMood),
                          'tags': _selectedEmotions.toList(),
                          'date': DateFormat('MMM dd, hh:mm a').format(DateTime.now()),
                          'timestamp': DateTime.now().toIso8601String(),
                        };
                        final updated = [..._savedMoodLogs, entry];
                        await PsynovaSyncService.saveMoodLogs(updated);
                        setState(() {
                          _savedMoodLogs = updated;
                        });

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Mood logged and saved to history!'),
                                backgroundColor: AppColors.moodEcstatic),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Weekly Mood Chart (fl_chart)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Weekly Mood Trends',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('${_savedMoodLogs.length} Saved Entries',
                      style: const TextStyle(fontSize: 12, color: AppColors.primaryIndigo, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              GlassContainer(
                height: 220,
                child: LineChart(
                  LineChartData(
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
                            const days = [
                              'Mon',
                              'Tue',
                              'Wed',
                              'Thu',
                              'Fri',
                              'Sat',
                              'Sun'
                            ];
                            if (val.toInt() >= 0 && val.toInt() < days.length) {
                              return Text(days[val.toInt()],
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondaryLight));
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _buildChartSpots(),
                        isCurved: true,
                        gradient: AppColors.primaryGradient,
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryIndigo.withValues(alpha: 0.3),
                              Colors.transparent
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Mood Insights Report
              GlassContainer(
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph_rounded,
                        color: AppColors.primaryPurple, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('AI Emotional Trend Report',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text(
                              _savedMoodLogs.isNotEmpty
                                  ? 'Log recorded: "${_savedMoodLogs.last['label']}". Active tags (${(_savedMoodLogs.last['tags'] as List).join(', ')}) indicate emotional self-awareness.'
                                  : 'Your mood has improved by +24% this week. Keeping gratitude tags active has strongly correlated with higher positivity scores.',
                              style: const TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 13)),
                        ],
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
}

