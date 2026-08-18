import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/features/auth/presentation/screens/reset_password/reset_password_email_screen.dart';
import 'package:lms/features/auth/presentation/screens/signin_screen.dart';
import 'package:lms/features/auth/presentation/screens/signup_screen.dart';
import 'package:lms/features/chat/presentation/screen/audio_call_screen.dart';
import 'package:lms/features/chat/presentation/screen/chat_screen.dart';
import 'package:lms/features/chat/presentation/screen/conversation_screen.dart';
import 'package:lms/features/chat/presentation/screen/video_call_screen.dart';
import 'package:lms/features/courses/presentation/screen/course_detail_screen.dart';
import 'package:lms/features/courses/presentation/screen/create_course_screen.dart';
import 'package:lms/features/courses/presentation/screen/my_course_screen.dart';
import 'package:lms/features/enrollment/presentation/screen/enrollment_screen.dart';
import 'package:lms/features/helpCenter/presentation/screen/help_center_screen.dart';
import 'package:lms/features/home/presentation/screens/home_screen.dart';
import 'package:lms/features/mainTab/presentation/screen/main_tab_screen.dart';
import 'package:lms/features/notification/presentation/screen/notification_screen.dart';
import 'package:lms/features/onboard/presentation/screens/onboard_screen.dart';
import 'package:lms/features/payment/presentation/screen/payment_methods_screen.dart';
import 'package:lms/features/profile/presentation/screen/edit_profile_screen.dart';
import 'package:lms/features/profile/presentation/screen/profile_screen.dart';
import 'package:lms/features/settings/presentation/screen/setting_screen.dart';
import 'package:lms/features/splash/presentation/screens/splash_screen.dart';
import 'package:lms/features/termsncondition/presentation/screen/termsncondition_screen.dart';

class Routes {
  static const String splash = '/';
  static const String onBoard = '/onboard_screen';
  static const String signin = '/signin_screen';
  static const String signup = '/signup_screen';
  static const String resetPassEmail = '/forgot_password_screen';
  static const String resetPass = '/reset_password_screen';
  static const String resetPassSuccess = '/reset_password_success_screen';
  static const String home = '/home_screen';
  static const String courseDetail = '/course/:id';
  static const String enrollmentScreen = '/enrollment';
  static const String notification = '/notification';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String course = '/course';
  static const String conversation = '/conversation';
  static const String call = '/calls';
  static const String audioCall = '/audioCall';
  static const String videoCall = '/videoCall';
  static const String editProfile = '/editProfile';
  static const String terms = '/termsnconditions';
  static const String payment = '/payment';
  static const String helpCenter = '/helpCenter';
  static const String createCourse = '/create_course';
}

// Global navigator key
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.splash,
    routes: [
      // Splash
      GoRoute(path: Routes.splash, builder: (context, index) => SplashScreen()),
      // OnBoard
      GoRoute(path: Routes.onBoard, builder: (context, index) => OnboardScreen()),
      // Signin
      GoRoute(path: Routes.signin, builder: (context, index) => SigninScreen()),
      // Signup
      GoRoute(path: Routes.signup, builder: (context, index) => SignupScreen()),
      // ForgotPassword
      GoRoute(path: Routes.resetPassEmail, builder: (context, index) => ResetPasswordEmailScreen()),
      // Course Detailed Screen
      GoRoute(
        path: Routes.courseDetail,
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      // Create Course Screen
      GoRoute(path: Routes.createCourse, builder: (context, index) => CreateCourseScreen()),
      // -------Screens with Persistent View-------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainTabScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              // Home
              GoRoute(path: Routes.home, builder: (context, state) => HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              // My Courses Screen
              GoRoute(path: Routes.course, builder: (context, state) => MyCoursesScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              // Chat
              GoRoute(
                path: Routes.chat,
                builder: (context, state) {
                  return ChatScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              // Profile
              GoRoute(path: Routes.profile, builder: (context, state) => ProfileScreen()),
            ],
          ),
        ],
      ),
      // Enrollment Screen
      GoRoute(path: Routes.enrollmentScreen, builder: (context, state) => const EnrollmentScreen()),
      // Notification Screen
      GoRoute(path: Routes.notification, builder: (context, state) => const NotificationsScreen()),
      // Settings Screen
      GoRoute(path: Routes.settings, builder: (context, state) => const SettingsScreen()),
      // Conversation Screen
      GoRoute(
        path: Routes.conversation,
        builder: (context, state) {
          final userId = state.uri.queryParameters['userId'] ?? '';
          final name = state.uri.queryParameters['name'] ?? 'User';

          return ConversationScreen(userId: userId, userName: name);
        },
      ),
      // Audio Call Screen
      GoRoute(path: Routes.audioCall, builder: (context, state) => const AudioCallScreen()),
      // Video Call Screen
      GoRoute(path: Routes.videoCall, builder: (context, state) => const VideoCallScreen()),
      // Edit Profile Screen
      GoRoute(path: Routes.editProfile, builder: (context, state) => const EditProfileScreen()),
      // Terms and Condition Screen Added
      GoRoute(path: Routes.terms, builder: (context, state) => const TermsAndConditionsScreen()),
      // Payment Screen
      GoRoute(path: Routes.payment, builder: (context, state) => const PaymentMethodsScreen()),
      // Help Center Screen
      GoRoute(path: Routes.helpCenter, builder: (context, state) => const HelpCenterScreen()),
    ],
  );
});
