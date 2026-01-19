class ApiConfig {
  /// Base URL
  static const String baseUrl = 'http://45.156.85.205:8080';
  static const String antiCheatBaseUrl = 'http://192.168.18.11:5001';

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
  static const String googleClientIdWeb =
      '762516784766-e1jiaep2bnstnhqcffvi3jqno8updlco.apps.googleusercontent.com';
}
