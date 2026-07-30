import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_container.dart';

class TherapistDetailScreen extends StatelessWidget {
  final String therapistId;
  const TherapistDetailScreen({super.key, required this.therapistId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Therapist Profile')),
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppColors.primaryIndigo,
                            child: Icon(Icons.person,
                                size: 60, color: Colors.white),
                          ),
                          SizedBox(height: 16),
                          Text('Dr. Sarah Jenkins, Psy.D',
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('Licensed Clinical Psychologist',
                              style: TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 15)),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_rounded,
                                  color: Colors.amber, size: 20),
                              Text(' 4.9 (38 Reviews) • 8 Years Exp.',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),

                    // Session Duration & Location Badge
                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            child: Column(
                              children: [
                                Text('Session Duration',
                                    style: TextStyle(
                                        color: AppColors.textSecondaryLight,
                                        fontSize: 12)),
                                SizedBox(height: 4),
                                Text('50 min Session',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryIndigo)),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: GlassContainer(
                            child: Column(
                              children: [
                                Text('Languages',
                                    style: TextStyle(
                                        color: AppColors.textSecondaryLight,
                                        fontSize: 12)),
                                SizedBox(height: 4),
                                Text('English, Spanish',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),

                    Text('About Therapist',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(
                      'Dr. Sarah Jenkins specializes in Cognitive Behavioral Therapy (CBT), anxiety management, and stress resilience. She holds a Doctorate in Clinical Psychology from Columbia University and has helped over 500+ clients achieve emotional balance.',
                      style: TextStyle(
                          height: 1.5, color: AppColors.textSecondaryLight),
                    ),
                    SizedBox(height: 24),

                    Text('Qualifications & Certificates',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            color: AppColors.primaryIndigo, size: 20),
                        SizedBox(width: 8),
                        Text(
                            'Psy.D in Clinical Psychology (Columbia University)'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            color: AppColors.primaryIndigo, size: 20),
                        SizedBox(width: 8),
                        Text('Licensed CBT Practitioner & Mindfulness Coach'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                children: [
                  IconButton.outlined(
                    icon: const Icon(Icons.chat_bubble_outline_rounded,
                        color: AppColors.primaryIndigo),
                    onPressed: () => context.push('/chat-detail/t-1'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Book Appointment',
                      onPressed: () =>
                          context.push('/book-appointment/$therapistId'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
