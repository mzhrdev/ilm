import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/features/auth/presentation/screens/reset_password/reset_password_email_screen.dart';
import 'package:lms/features/auth/presentation/screens/reset_password/reset_password_screen.dart';
import 'package:lms/features/auth/presentation/screens/reset_password/reset_password_success_screen.dart';
import 'package:lms/features/auth/presentation/screens/signin_screen.dart';
import 'package:lms/features/auth/presentation/screens/signup_screen.dart';
import 'package:lms/features/auth/presentation/screens/user_type_selection_screen.dart';
import 'package:lms/features/chat/presentation/screen/chat_screen.dart';
import 'package:lms/features/chat/presentation/screen/conversation_screen.dart';
import 'package:lms/features/courses/presentation/screen/course_detail_screen.dart';
import 'package:lms/features/courses/presentation/screen/course_screen.dart';
import 'package:lms/features/enrollment/presentation/screen/enrollment_screen.dart';
import 'package:lms/features/home/presentation/screens/home_screen.dart';
import 'package:lms/features/notification/presentation/screen/notification_screen.dart';
import 'package:lms/features/onboard/presentation/screens/onboard_screen.dart';
import 'package:lms/features/profile/presentation/screen/profile_screen.dart';
import 'package:lms/features/settings/presentation/screen/setting_screen.dart';
import 'package:lms/features/splash/presentation/screens/splash_screen.dart';

class Routes {
  static const String splash = '/';
  static const String onBoard = '/onboard_screen';
  static const String signin = '/signin_screen';
  static const String userType = '/user_type_Selection_screen';
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
      // UserTypeSelection
      GoRoute(path: Routes.userType, builder: (context, index) => UserTypeSelectionScreen()),
      // Signin
      GoRoute(path: Routes.signin, builder: (context, index) => SigninScreen()),
      // Signup
      GoRoute(path: Routes.signup, builder: (context, index) => SignupScreen()),
      // ForgotPassword
      GoRoute(path: Routes.resetPassEmail, builder: (context, index) => ResetPasswordEmailScreen()),
      // Reset Password Screen
      GoRoute(path: Routes.resetPass, builder: (context, index) => ResetPasswordScreen()),
      // Reset Password Success Screen
      GoRoute(path: Routes.resetPassSuccess, builder: (context, index) => ResetPasswordSuccessScreen()),
      // Home Screen
      GoRoute(path: Routes.home, builder: (context, index) => HomeScreen()),
      // Course Detailed Screen
      GoRoute(
        path: Routes.courseDetail,
        builder: (context, state) {
          final courseId = state.pathParameters['id']!;
          return CourseDetailScreen(courseId: courseId);
        },
      ),
      // Enrollment Screen
      GoRoute(path: Routes.enrollmentScreen, builder: (context, state) => const EnrollmentScreen()),
      // Notification Screen
      GoRoute(path: Routes.notification, builder: (context, state) => const NotificationsScreen()),
      // Settings Screen
      GoRoute(path: Routes.settings, builder: (context, state) => const SettingsScreen()),
      // Profile Screen
      GoRoute(path: Routes.profile, builder: (context, state) => const ProfileScreen()),
      // Chat Screen
      GoRoute(path: Routes.chat, builder: (context, state) => const ChatScreen()),
      // Course Screen
      GoRoute(path: Routes.course, builder: (context, state) => const MyCoursesScreen()),
      // Conversation Screen
      GoRoute(
        path: Routes.conversation,
        builder: (context, state) {
          // Extract the 'name' query parameter from the URL
          final name = state.uri.queryParameters['name'] ?? 'User';
          return ConversationScreen(userName: name);
        },
      ),
    ],
  );
});
