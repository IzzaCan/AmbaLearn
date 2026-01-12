import 'package:flutter/foundation.dart';

class ApiConfig {
  /// Base URL
  // "adb reverse" wont work for built apps. Use your PC's LAN IP instead.
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8080';
    }
    // Android Emulator
    return 'http://10.0.2.2:8080';
    // HP fisik → ganti IP LAN
    // return 'http://192.168.1.10:8080';
  }

  /// Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 120);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Auth
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String currentUser = '/@me';
  static const String googleAuth = '/auth/google';

  /// Courses
  static const String courses = '/courses';
  static const String generateCourse = '/generate_course';
  static String courseDetail(String uid) => '/course/$uid';
  static String courseStepChat(String uid, int step) =>
      '/course/$uid/step/$step/chat';

  /// Exam
  static String courseExam(String uid) => '/course/$uid/exam';
  static String submitCourseExam(String uid) => '/course/$uid/exam/submit';

  /// Chat Sessions
  static const String chat = '/chat';
  static const String createSession = '/create_session';
  static const String listSessions = '/list_sessions';
  static String getSession(String uid) => '/get_session/$uid';

  /// Google Auth Client
  static const String googleClientIdAndroid =
      '916823130703-05gh5fr437sb3bstdarmf55udgvj6gcc.apps.googleusercontent.com';
  static const String googleClientIdWeb =
      '916823130703-05gh5fr437sb3bstdarmf55udgvj6gcc.apps.googleusercontent.com';
}
