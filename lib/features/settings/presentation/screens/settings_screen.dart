import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _aiReminders = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              GlassContainer(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Dark Mode Theme'),
                      secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryIndigo),
                      value: _darkMode,
                      onChanged: (val) => setState(() => _darkMode = val),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Push Notifications'),
                      subtitle: const Text('Therapy session alerts & chat reminders'),
                      secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.primaryIndigo),
                      value: _pushNotifications,
                      onChanged: (val) => setState(() => _pushNotifications = val),
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('AI Daily Mood Check-in Alerts'),
                      subtitle: const Text('Personalized wellness & journal nudges'),
                      secondary: const Icon(Icons.auto_awesome_outlined, color: AppColors.primaryPurple),
                      value: _aiReminders,
                      onChanged: (val) => setState(() => _aiReminders = val),
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
