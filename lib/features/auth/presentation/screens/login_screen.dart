import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String role;
  const LoginScreen({super.key, required this.role});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = '';
    _passwordController.text = '';
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        role: widget.role,
      );

      if (success && mounted) {
        final authState = ref.read(authProvider);
        if (authState.user?.role == 'therapist') {
          context.go('/therapist-dashboard');
        } else {
          context.go('/client-dashboard');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isTherapist = widget.role == 'therapist';

    return Scaffold(
      appBar: AppBar(title: Text(isTherapist ? 'Therapist Login' : 'Client Login')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Icon(
                  isTherapist ? Icons.medical_services_rounded : Icons.person_rounded,
                  size: 70,
                  color: isTherapist ? AppColors.primaryPurple : AppColors.primaryIndigo,
                ),
                const SizedBox(height: 20),
                Text(
                  isTherapist ? 'Therapist Clinical Portal' : 'Client Portal',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email and password to sign into ${isTherapist ? "Psynova AI Therapist Dashboard" : "Client Dashboard"}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email Address',
                  hintText: isTherapist ? 'e.g. aishu@psynova.com' : 'e.g. client@gmail.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) => val == null || val.isEmpty ? 'Please enter your password' : null,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Sign In',
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        if (isTherapist) {
                          context.push('/register/therapist');
                        } else {
                          context.push('/register/client');
                        }
                      },
                      child: Text(
                        'Register Now',
                        style: TextStyle(fontWeight: FontWeight.bold, color: isTherapist ? AppColors.primaryPurple : AppColors.primaryIndigo),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
