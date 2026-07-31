import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';

class TherapistVideoCallScreen extends StatelessWidget {
  const TherapistVideoCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Therapist E2EE Clinical Platform 🔒'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, size: 70, color: AppColors.primaryPurple),
              ),
              const SizedBox(height: 24),
              Text(
                'Clinical E2EE Encrypted Session Platform',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 10),
              const Text(
                'All client consultations occur on our 100% end-to-end encrypted messaging platform. Initiate or review client clinical notes and chat sessions securely.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Open Clinical Session Messages 💬',
                onPressed: () => context.go('/therapist-messages'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/therapist-notes'),
                child: const Text('Open SOAP Notes Scratchpad'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

