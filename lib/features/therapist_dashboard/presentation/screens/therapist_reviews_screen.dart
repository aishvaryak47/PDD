import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class TherapistReviewsScreen extends StatelessWidget {
  const TherapistReviewsScreen({super.key});

  final List<Map<String, dynamic>> _reviews = const [
    {
      'name': 'Client A. M.',
      'date': 'July 26, 2026',
      'rating': 5.0,
      'comment': 'Dr. Sarah has been instrumental in helping me manage panic attacks. Her CBT exercises and warm demeanor made a huge difference.',
      'tag': 'CBT / Anxiety',
    },
    {
      'name': 'Client E. W.',
      'date': 'July 20, 2026',
      'rating': 5.0,
      'comment': 'Exceptional clinical insight! The pre-session notes and AI homework tracking keep me accountable.',
      'tag': 'Depression',
    },
    {
      'name': 'Client D. M.',
      'date': 'July 14, 2026',
      'rating': 4.8,
      'comment': 'Very empathetic therapist. Highly recommended for trauma and PTSD recovery.',
      'tag': 'PTSD Recovery',
    },
  ];

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
                    'Patient Reviews & Practice Rating ⭐',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Verified patient feedback, satisfaction analytics & clinical reviews',
                    style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Rating Summary Card
              GlassContainer(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Column(
                      children: [
                        Text('4.9', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            Icon(Icons.star, color: Colors.amber, size: 18),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text('Based on 48 Reviews', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 11)),
                      ],
                    ),
                    Container(height: 60, width: 1, color: Colors.grey.shade300),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• 98% Positive Feedback', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.moodEcstatic)),
                        SizedBox(height: 4),
                        Text('• 100% Response Rate', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryPurple)),
                        SizedBox(height: 4),
                        Text('• Top Rated CBT Practitioner', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryIndigo)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reviews List
              const Text('Recent Patient Testimonials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _reviews.length,
                itemBuilder: (context, index) {
                  final r = _reviews[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(r['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                  const SizedBox(width: 4),
                                  Text('${r['rating']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(r['date'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                          const SizedBox(height: 10),
                          Text('"${r['comment']}"', style: const TextStyle(fontSize: 13, height: 1.35, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
