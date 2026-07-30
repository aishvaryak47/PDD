import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';

class TherapistAppointmentsScreen extends StatefulWidget {
  const TherapistAppointmentsScreen({super.key});

  @override
  State<TherapistAppointmentsScreen> createState() => _TherapistAppointmentsScreenState();
}

class _TherapistAppointmentsScreenState extends State<TherapistAppointmentsScreen> {
  final List<Map<String, dynamic>> _requests = [];

  void _showAddSessionDialog() {
    final nameController = TextEditingController();
    final timeController = TextEditingController(text: 'Tomorrow • 11:00 AM');
    final typeController = TextEditingController(text: 'CBT Consultation');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Booking Request', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Client Name', hintText: 'e.g. Alex Morgan'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Proposed Time', hintText: 'e.g. Tomorrow • 11:00 AM'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'Session Type', hintText: 'e.g. Initial Consultation'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _requests.add({
                    'id': 'a-${DateTime.now().millisecondsSinceEpoch}',
                    'client': nameController.text.trim(),
                    'time': timeController.text.trim(),
                    'type': typeController.text.trim(),
                    'status': 'pending',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added appointment request for ${nameController.text.trim()}!'), backgroundColor: AppColors.moodEcstatic),
                );
              }
            },
            child: const Text('Add Request', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Requests & Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: _showAddSessionDialog,
            tooltip: 'Add Session Request',
          ),
        ],
      ),
      body: SafeArea(
        child: _requests.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: GlassContainer(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 48, color: AppColors.primaryPurple),
                          const SizedBox(height: 12),
                          const Text('No Pending Booking Requests', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          const Text('Client appointment booking requests will appear here.', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight), textAlign: TextAlign.center),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                            label: const Text('+ Add Booking Request', style: TextStyle(color: Colors.white)),
                            onPressed: _showAddSessionDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pending Booking Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                        label: const Text('+ Add Request', style: TextStyle(color: Colors.white, fontSize: 11)),
                        onPressed: _showAddSessionDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final req in _requests)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: GlassContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(radius: 20, backgroundColor: AppColors.primaryPurple, child: Icon(Icons.person, color: Colors.white, size: 24)),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(req['client'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(req['type'], style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primaryPurple),
                                const SizedBox(width: 6),
                                Text(req['time'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (req['status'] == 'pending')
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                      onPressed: () {
                                        setState(() => req['status'] = 'rejected');
                                      },
                                      child: const Text('Reject', style: TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.moodEcstatic),
                                      onPressed: () {
                                        setState(() => req['status'] = 'accepted');
                                      },
                                      child: const Text('Accept Booking', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: req['status'] == 'accepted' ? AppColors.moodEcstatic.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  req['status'] == 'accepted' ? 'Booking Accepted' : 'Booking Rejected',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: req['status'] == 'accepted' ? AppColors.moodEcstatic : Colors.red),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
