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
      appBar: AppBar(
        title: Text(isTherapist ? 'Therapist Login' : 'Client Login'),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go('/login?role=${isTherapist ? 'client' : 'therapist'}');
            },
            icon: Icon(
              isTherapist ? Icons.person_outline : Icons.medical_services_outlined,
              size: 18,
              color: isTherapist ? AppColors.primaryIndigo : AppColors.primaryPurple,
            ),
            label: Text(
              isTherapist ? 'Client Portal' : 'Therapist Portal',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isTherapist ? AppColors.primaryIndigo : AppColors.primaryPurple,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                // Prominent Role Banner / Switcher
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: (isTherapist ? AppColors.primaryPurple : AppColors.primaryIndigo).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isTherapist ? AppColors.primaryPurple : AppColors.primaryIndigo).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isTherapist ? Icons.medical_services_outlined : Icons.person_outline,
                            color: isTherapist ? AppColors.primaryPurple : AppColors.primaryIndigo,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isTherapist ? 'Therapist Mode' : 'Client Mode',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isTherapist ? AppColors.primaryPurple : AppColors.primaryIndigo,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          context.go('/login?role=${isTherapist ? 'client' : 'therapist'}');
                        },
                        child: Text(
                          isTherapist ? 'Switch to Client Login' : 'Switch to Therapist Login',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            color: isTherapist ? AppColors.primaryPurple : AppColors.primaryIndigo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                  hintText: isTherapist ? 'e.g. aishu@psynova.com or dr.jenkins@psynova.com' : 'e.g. client@gmail.com',
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
                const SizedBox(height: 24),
                CustomButton(
                  text: isTherapist ? 'Sign In as Therapist' : 'Sign In as Client',
                  isLoading: authState.isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.go('/login?role=${isTherapist ? "client" : "therapist"}');
                    },
                    child: Text(
                      isTherapist
                          ? 'Are you a Client? Click here to switch to Client Login'
                          : 'Are you a Therapist? Click here for Therapist Login',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isTherapist ? AppColors.primaryIndigo : AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        isTherapist ? 'Register as Therapist' : 'Register Now',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isTherapist ? AppColors.primaryPurple : AppColors.primaryIndigo),
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
