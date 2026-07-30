import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class VideoConsultationScreen extends StatefulWidget {
  const VideoConsultationScreen({super.key});

  @override
  State<VideoConsultationScreen> createState() => _VideoConsultationScreenState();
}

class _VideoConsultationScreenState extends State<VideoConsultationScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Video View (Therapist Stream)
            Center(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: const Color(0xFF1E293B),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.primaryIndigo,
                      child: Icon(Icons.person, size: 80, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    const Text('Dr. Sarah Jenkins', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                          SizedBox(width: 6),
                          Text('HD WebRTC Video • 14:28', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Local Video Preview PIP (Client Stream)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 110,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white30, width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      Center(
                        child: _isVideoOff
                            ? const Icon(Icons.videocam_off, color: Colors.white54)
                            : const Icon(Icons.person, color: Colors.white70, size: 40),
                      ),
                      const Positioned(
                        bottom: 8,
                        left: 8,
                        child: Text('You', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Floating Controls Bar
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(_isMuted ? Icons.mic_off_rounded : Icons.mic_rounded, color: Colors.white),
                      onPressed: () => setState(() => _isMuted = !_isMuted),
                    ),
                    IconButton(
                      icon: Icon(_isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded, color: Colors.white),
                      onPressed: () => setState(() => _isVideoOff = !_isVideoOff),
                    ),
                    IconButton.filled(
                      icon: const Icon(Icons.call_end_rounded, color: Colors.white),
                      style: IconButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session ended.')));
                        context.pop();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                      onPressed: () => context.push('/chat-detail/t-1'),
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
