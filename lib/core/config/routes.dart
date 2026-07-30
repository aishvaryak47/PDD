import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/client_register_screen.dart';
import '../../features/auth/presentation/screens/therapist_register_screen.dart';

import '../../features/client_dashboard/presentation/screens/client_shell_screen.dart';
import '../../features/client_dashboard/presentation/screens/client_dashboard_screen.dart';
import '../../features/therapist_discovery/presentation/screens/nearby_therapists_screen.dart';
import '../../features/therapist_discovery/presentation/screens/therapist_detail_screen.dart';
import '../../features/appointments/presentation/screens/book_appointment_screen.dart';
import '../../features/appointments/presentation/screens/client_appointments_screen.dart';
import '../../features/mood_tracker/presentation/screens/mood_tracker_screen.dart';
import '../../features/journal/presentation/screens/journal_screen.dart';
import '../../features/ai_assistant/presentation/screens/ai_chat_screen.dart';
import '../../features/messaging/presentation/screens/chat_detail_screen.dart';
import '../../features/profile/presentation/screens/client_profile_screen.dart';
import '../../features/video_consultation/presentation/screens/video_consultation_screen.dart';

import '../../features/therapist_dashboard/presentation/screens/therapist_shell_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_dashboard_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_appointments_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_crm_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_notes_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_analytics_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_messaging_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_profile_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_reviews_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_ai_copilot_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_nearby_map_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_video_call_screen.dart';
import '../../features/therapist_dashboard/presentation/screens/therapist_revenue_screen.dart';

import '../../features/settings/presentation/screens/settings_screen.dart';

final routerConfig = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen()),
    GoRoute(
        path: '/welcome', builder: (context, state) => const WelcomeScreen()),
    GoRoute(
      path: '/login',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'client';
        return LoginScreen(role: role);
      },
    ),
    GoRoute(
        path: '/register/client',
        builder: (context, state) => const ClientRegisterScreen()),
    GoRoute(
        path: '/register/therapist',
        builder: (context, state) => const TherapistRegisterScreen()),

    // Client Navigation Shell
    ShellRoute(
      builder: (context, state, child) => ClientShellScreen(child: child),
      routes: [
        GoRoute(
            path: '/client-dashboard',
            builder: (context, state) => const ClientDashboardScreen()),
        GoRoute(
            path: '/nearby-therapists',
            builder: (context, state) => const NearbyTherapistsScreen()),
        GoRoute(
            path: '/ai-chat',
            builder: (context, state) => const AIChatScreen()),
        GoRoute(
            path: '/mood-tracker',
            builder: (context, state) => const MoodTrackerScreen()),
        GoRoute(
            path: '/client-appointments',
            builder: (context, state) => const ClientAppointmentsScreen()),
      ],
    ),

    // Essential Therapist Navigation Shell
    ShellRoute(
      builder: (context, state, child) => TherapistShellScreen(child: child),
      routes: [
        GoRoute(
            path: '/therapist-dashboard',
            builder: (context, state) => const TherapistDashboardScreen()),
        GoRoute(
            path: '/client-management',
            builder: (context, state) => const TherapistCrmScreen()),
        GoRoute(
            path: '/therapist-appointments',
            builder: (context, state) => const TherapistAppointmentsScreen()),
        GoRoute(
            path: '/therapist-messages',
            builder: (context, state) => const TherapistMessagingScreen()),
        GoRoute(
            path: '/therapist-notes',
            builder: (context, state) => const TherapistNotesScreen()),
        GoRoute(
            path: '/therapist-analytics',
            builder: (context, state) => const TherapistAnalyticsScreen()),
        GoRoute(
            path: '/therapist-profile',
            builder: (context, state) => const TherapistProfileScreen()),
        GoRoute(
            path: '/therapist-reviews',
            builder: (context, state) => const TherapistReviewsScreen()),
        GoRoute(
            path: '/therapist-ai-copilot',
            builder: (context, state) => const TherapistAiCopilotScreen()),
        GoRoute(
            path: '/therapist-nearby-map',
            builder: (context, state) => const TherapistNearbyMapScreen()),
        GoRoute(
            path: '/therapist-video-call',
            builder: (context, state) => const TherapistVideoCallScreen()),
        GoRoute(
            path: '/therapist-revenue',
            builder: (context, state) => const TherapistRevenueScreen()),
      ],
    ),

    // Standalone & Detail Routes
    GoRoute(
      path: '/therapist-detail/:id',
      builder: (context, state) =>
          TherapistDetailScreen(therapistId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
      path: '/book-appointment/:id',
      builder: (context, state) =>
          BookAppointmentScreen(therapistId: state.pathParameters['id'] ?? ''),
    ),
    GoRoute(
        path: '/journal', builder: (context, state) => const JournalScreen()),
    GoRoute(
      path: '/chat-detail/:userId',
      builder: (context, state) =>
          ChatDetailScreen(userId: state.pathParameters['userId'] ?? ''),
    ),
    GoRoute(
        path: '/client-profile',
        builder: (context, state) => const ClientProfileScreen()),
    GoRoute(
        path: '/video-consultation',
        builder: (context, state) => const VideoConsultationScreen()),
    GoRoute(
        path: '/settings', builder: (context, state) => const SettingsScreen()),
  ],
);
