import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/services/psynova_sync_service.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../therapist_dashboard/presentation/providers/therapist_provider.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final String therapistId;
  const BookAppointmentScreen({super.key, required this.therapistId});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '10:00 AM';

  final List<String> _timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:30 AM',
    '02:00 PM',
    '04:00 PM',
    '05:30 PM'
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final displayName = (user?.fullName != null && user!.fullName.isNotEmpty)
        ? user.fullName
        : (user?.email != null ? user!.email.split('@')[0] : "Client User");

    return Scaffold(
      appBar: AppBar(title: const Text('Book Therapy Session')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlassContainer(
                      child: Row(
                        children: [
                          CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.primaryIndigo,
                              child: Icon(Icons.person, color: Colors.white)),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dr. Sarah Jenkins',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              SizedBox(height: 4),
                              Text('50 Min Therapy Consultation',
                                  style: TextStyle(
                                      color: AppColors.textSecondaryLight,
                                      fontSize: 13)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Select Date',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    CalendarDatePicker(
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 60)),
                      onDateChanged: (date) =>
                          setState(() => _selectedDate = date),
                    ),
                    const SizedBox(height: 24),
                    const Text('Available Time Slots',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _timeSlots.map((slot) {
                        final isSelected = slot == _selectedSlot;
                        return ChoiceChip(
                          label: Text(slot,
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                  fontWeight: FontWeight.bold)),
                          selected: isSelected,
                          selectedColor: AppColors.primaryIndigo,
                          backgroundColor: Colors.transparent,
                          onSelected: (val) =>
                              setState(() => _selectedSlot = slot),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CustomButton(
                text: 'Confirm Session Schedule',
                onPressed: () async {
                  final formattedDate = DateFormat('MMM dd, yyyy').format(_selectedDate);
                  final newApt = {
                    'id': 'apt-${DateTime.now().millisecondsSinceEpoch}',
                    'clientName': displayName,
                    'therapistName': 'Dr. Sarah Jenkins',
                    'avatar': 'https://i.pravatar.cc/150?img=12',
                    'date': formattedDate,
                    'time': '$_selectedSlot ($formattedDate)',
                    'type': 'Cognitive Behavioral Therapy (50m)',
                    'status': 'Upcoming',
                    'risk': 'Stable',
                    'isUrgent': false,
                  };

                  final existing = await PsynovaSyncService.loadAppointments();
                  existing.insert(0, newApt);
                  await PsynovaSyncService.saveAppointments(existing);
                  ref.read(therapistProvider.notifier).addAppointment(newApt);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Appointment booked successfully!'),
                          backgroundColor: AppColors.moodEcstatic),
                    );
                    context.go('/client-appointments');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

