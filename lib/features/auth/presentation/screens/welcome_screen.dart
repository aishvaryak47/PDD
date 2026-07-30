import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/custom_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Text(
                'Welcome to PSYNOVA',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 32, color: AppColors.primaryIndigo),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select your portal to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 50),

              // Client Role Selection Card
              GlassContainer(
                onTap: () => context.push('/login?role=client'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_outline_rounded,
                          size: 36, color: AppColors.primaryIndigo),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('I am a Client',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                              'Seek therapy, track mood, write journals & chat with AI.',
                              style: TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 18, color: AppColors.textSecondaryLight),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Therapist Role Selection Card
              GlassContainer(
                onTap: () => context.push('/login?role=therapist'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.medical_services_outlined,
                          size: 36, color: AppColors.primaryPurple),
                    ),
                    const SizedBox(width: 20),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('I am a Therapist',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                              'Manage clients, appointments, session notes & revenue.',
                              style: TextStyle(
                                  color: AppColors.textSecondaryLight,
                                  fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 18, color: AppColors.textSecondaryLight),
                  ],
                ),
              ),

              const Spacer(),

              CustomButton(
                text: 'Create New Account',
                onPressed: () => context.push('/register/client'),
                isOutlined: true,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
