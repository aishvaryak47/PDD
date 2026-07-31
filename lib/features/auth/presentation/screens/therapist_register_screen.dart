import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class TherapistRegisterScreen extends ConsumerStatefulWidget {
  const TherapistRegisterScreen({super.key});

  @override
  ConsumerState<TherapistRegisterScreen> createState() => _TherapistRegisterScreenState();
}

class _TherapistRegisterScreenState extends ConsumerState<TherapistRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _titleController = TextEditingController(text: 'Licensed Clinical Specialist');
  final _qualificationsController = TextEditingController(text: 'Psy.D in Clinical Psychology, Licensed CBT Specialist');
  final _expController = TextEditingController(text: '8');
  final _bioController = TextEditingController();

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final quals = _qualificationsController.text
          .split(',')
          .map((q) => q.trim())
          .where((q) => q.isNotEmpty)
          .toList();
      final expYears = int.tryParse(_expController.text.trim()) ?? 5;

      final success = await ref.read(authProvider.notifier).registerTherapist(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        title: _titleController.text.trim(),
        biography: _bioController.text.trim(),
        qualifications: quals.isNotEmpty ? quals : ['Licensed Specialist'],
        experienceYears: expYears,
      );

      if (success && mounted) {
        context.go('/therapist-dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Therapist Registration')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Join PSYNOVA Clinical Network',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Provide your professional qualifications & experience to accept clients.',
                  style: TextStyle(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name & Titles',
                  prefixIcon: Icons.person_outline,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Professional Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || !val.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  validator: (val) => val == null || val.length < 6 ? 'Password must be at least 6 chars' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _titleController,
                  labelText: 'Professional Title',
                  prefixIcon: Icons.medical_information_outlined,
                  validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _qualificationsController,
                  labelText: 'Qualifications & Certifications (Comma separated)',
                  prefixIcon: Icons.verified_outlined,
                  hintText: 'e.g. Psy.D in Psychology, CBT Specialist',
                  validator: (val) => val == null || val.isEmpty ? 'Qualifications are required' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _expController,
                  labelText: 'Years of Experience',
                  prefixIcon: Icons.work_history_outlined,
                  keyboardType: TextInputType.number,
                  hintText: 'e.g. 8',
                  validator: (val) => val == null || val.isEmpty ? 'Please enter years of experience' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _bioController,
                  labelText: 'Short Biography',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (val) => val == null || val.isEmpty ? 'Please enter a bio' : null,
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Register as Licensed Therapist',
                  isLoading: authState.isLoading,
                  onPressed: _handleRegister,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
