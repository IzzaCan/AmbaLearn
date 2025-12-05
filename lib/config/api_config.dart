class ApiConfig {
  /// Base URL
  static const String baseUrl = 'http://185.239.239.135:8080';

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
  static String courseExam(String uid) => '/course/$uid/exam';

  /// Chat Sessions
  static const String chat = '/chat';
  static const String createSession = '/create_session';
  static const String listSessions = '/list_sessions';
  static String getSession(String uid) => '/get_session/$uid';

  /// Google Auth Client
  // static const String googleClientIdWeb =
  //     '518875508230-melh43klsocgbte9qiluo8220koupgi9.apps.googleusercontent.com';
  // static const String googleClientIdAndroid =
  //     '518875508230-9did8037674mirbapr4bjs3l9gapt9a4.apps.googleusercontent.com';
}
