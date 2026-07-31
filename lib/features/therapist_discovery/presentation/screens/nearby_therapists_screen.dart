import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/providers/active_therapists_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class NearbyTherapistsScreen extends ConsumerStatefulWidget {
  const NearbyTherapistsScreen({super.key});

  @override
  ConsumerState<NearbyTherapistsScreen> createState() => _NearbyTherapistsScreenState();
}

class _NearbyTherapistsScreenState extends ConsumerState<NearbyTherapistsScreen> {
  final _searchController = TextEditingController();
  bool _isMapView = false;

  @override
  Widget build(BuildContext context) {
    final activeTherapists = ref.watch(activeTherapistsProvider);
    final user = ref.watch(authProvider).user;
    final search = _searchController.text.trim().toLowerCase();

    // Dynamically build active list including currently logged-in therapist user
    final List<ActiveTherapist> allActive = [...activeTherapists];

    if (user != null && user.role == 'therapist') {
      final exists = allActive.any((t) => t.id == user.id || t.name == user.fullName);
      if (!exists) {
        allActive.insert(
          0,
          ActiveTherapist(
            id: user.id,
            name: user.fullName.isNotEmpty ? (user.fullName.toLowerCase().startsWith('dr') ? user.fullName : 'Dr. ${user.fullName}') : 'Dr. Specialist',
            title: 'Licensed Clinical Specialist (Active)',
            rate: '\$140 / hr',
            rating: 5.0,
            reviews: 12,
            address: 'Active Online Clinical Suite',
            isOnline: true,
          ),
        );
      }
    }

    final filteredTherapists = allActive.where((t) {
      if (search.isEmpty) return true;
      return t.name.toLowerCase().contains(search) || t.title.toLowerCase().contains(search);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Nearby Therapists'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.format_list_bulleted_rounded : Icons.map_rounded),
            onPressed: () => setState(() => _isMapView = !_isMapView),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomTextField(
                controller: _searchController,
                labelText: 'Search therapist or specialty...',
                prefixIcon: Icons.search_rounded,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              
              _isMapView
                  ? Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primaryIndigo.withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.map_rounded, size: 70, color: AppColors.primaryIndigo),
                              const SizedBox(height: 16),
                              const Text('Interactive Map View', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                              const SizedBox(height: 8),
                              Text('Showing ${filteredTherapists.length} active logged-in therapists nearby', style: const TextStyle(color: AppColors.textSecondaryLight)),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.my_location_rounded),
                                label: const Text('Locate Me'),
                                onPressed: () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: filteredTherapists.isEmpty
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_off_rounded, size: 70, color: AppColors.textSecondaryLight),
                                  SizedBox(height: 16),
                                  Text(
                                    'No Active Therapists Logged In',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                                    child: Text(
                                      'There are currently no active therapists logged into the portal. Therapists will automatically appear here in real-time as soon as they log into their account.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredTherapists.length,
                              itemBuilder: (context, index) {
                                final t = filteredTherapists[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: GlassContainer(
                                    onTap: () => context.push('/therapist-detail/${t.id}'),
                                    child: Row(
                                      children: [
                                        Stack(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundColor: AppColors.primaryIndigo.withValues(alpha: 0.2),
                                              child: Text(
                                                t.name.isNotEmpty ? t.name[0] : 'D',
                                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryIndigo),
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                width: 14,
                                                height: 14,
                                                decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 2),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      t.name,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.circle, color: Colors.green, size: 8),
                                                        SizedBox(width: 4),
                                                        Text('Active Now', style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(t.title, style: const TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                                  Text(' ${t.rating} (${t.reviews} Reviews) • ', style: const TextStyle(fontSize: 12)),
                                                  Text(t.rate, style: const TextStyle(color: AppColors.primaryIndigo, fontSize: 12, fontWeight: FontWeight.bold)),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                         const SizedBox(width: 10),
                                         Container(
                                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                           decoration: BoxDecoration(
                                             color: AppColors.primaryIndigo.withValues(alpha: 0.1),
                                             borderRadius: BorderRadius.circular(8),
                                           ),
                                           child: const Text('Book Session', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryIndigo)),
                                         ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
