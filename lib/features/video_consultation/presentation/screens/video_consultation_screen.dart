import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/providers/active_therapists_provider.dart';

class VideoConsultationScreen extends ConsumerWidget {
  const VideoConsultationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTherapists = ref.watch(activeTherapistsProvider);
    final therapistName = activeTherapists.isNotEmpty ? activeTherapists.first.name : 'Licensed Specialist';

    return Scaffold(
      appBar: AppBar(
        title: const Text('E2EE Session Platform 🔒'),
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
                  color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, size: 70, color: AppColors.primaryIndigo),
              ),
              const SizedBox(height: 24),
              Text(
                'End-to-End Encrypted Therapy Session',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 10),
              Text(
                'All sessions are conducted strictly on our 100% private, E2EE encrypted chat platform with $therapistName. No video or audio call initiation required.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Open Encrypted Session Chat 💬',
                onPressed: () => context.push('/chat-detail/t-1'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

