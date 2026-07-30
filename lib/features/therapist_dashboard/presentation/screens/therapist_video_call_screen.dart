import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class TherapistVideoCallScreen extends StatefulWidget {
  const TherapistVideoCallScreen({super.key});

  @override
  State<TherapistVideoCallScreen> createState() => _TherapistVideoCallScreenState();
}

class _TherapistVideoCallScreenState extends State<TherapistVideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isScreenSharing = false;
  bool _showLiveNotes = true;

  final List<String> _liveTranscripts = [
    '10:02 AM - Alex: "I had a panic spike on Tuesday night before the team lead presentation."',
    '10:03 AM - Dr. Sarah: "What physical sensations did you notice first during the spike?"',
    '10:04 AM - Alex: "Tightness in my chest and my heart was racing fast."',
    '10:05 AM - AI Note: Detected elevated speech tempo & anxiety keywords.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            // Video Header Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                            SizedBox(width: 6),
                            Text('REC • 24:18', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Telehealth Session: Alex Morgan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  IconButton(
                    icon: Icon(_showLiveNotes ? Icons.edit_note_rounded : Icons.edit_note_outlined, color: Colors.white),
                    onPressed: () => setState(() => _showLiveNotes = !_showLiveNotes),
                    tooltip: 'Toggle Live SOAP Scratchpad',
                  ),
                ],
              ),
            ),

            // Video Main View Area
            Expanded(
              child: Row(
                children: [
                  // Client Main Video View
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Client Name Badge
                          Positioned(
                            left: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(12)),
                              child: const Text('Alex Morgan (Client)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                          ),
                          // Practitioner Floating PIP Window
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Container(
                              width: 140,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24, width: 2),
                                image: const DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&w=400&q=80'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Live AI Transcription & Scratchpad Panel
                  if (_showLiveNotes)
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AI Speech Transcript & Live SOAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _liveTranscripts.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      _liveTranscripts[index],
                                      style: TextStyle(
                                        color: _liveTranscripts[index].contains('AI Note') ? AppColors.primaryPurple : Colors.white70,
                                        fontSize: 12,
                                        height: 1.3,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const Divider(color: Colors.white24),
                            const Text('Quick Live Scratchpad', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            const SizedBox(height: 4),
                            TextField(
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              decoration: InputDecoration(
                                hintText: 'Type immediate clinical observations here...',
                                hintStyle: const TextStyle(color: Colors.white38),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white24)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Telehealth Control Bar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: const Color(0xFF0F172A),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCallBtn(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    color: _isMuted ? Colors.red : Colors.grey.shade800,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),
                  const SizedBox(width: 16),
                  _buildCallBtn(
                    icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    color: _isCameraOff ? Colors.red : Colors.grey.shade800,
                    onTap: () => setState(() => _isCameraOff = !_isCameraOff),
                  ),
                  const SizedBox(width: 16),
                  _buildCallBtn(
                    icon: Icons.screen_share_rounded,
                    color: _isScreenSharing ? AppColors.primaryPurple : Colors.grey.shade800,
                    onTap: () => setState(() => _isScreenSharing = !_isScreenSharing),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                    label: const Text('End Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
