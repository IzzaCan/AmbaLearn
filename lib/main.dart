import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/homepage.dart';
import 'pages/courses.dart';
import 'pages/lessons.dart';
import 'pages/loginpage.dart';
import 'pages/registerpage.dart';
import 'pages/user_settings_page.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/course_provider.dart';
import 'providers/exam_provider.dart';
// import 'pages/exam_result_page.dart';
// import 'package:capstone_layout/pages/exam_page.dart';
// import 'package:capstone_layout/pages/exam_permission_page.dart';

void main() {
  runApp(const AmbaLearn());
}

class AmbaLearn extends StatelessWidget {
  const AmbaLearn({super.key});

  @override
  Widget build(BuildContext context) {
    // We change ChangeNotifierProvider to MultiProvider to hold multiple states
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "AmbaLearn",
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const HomePage(),
          '/user_settings': (context) => const UserSettingPage(),
          '/courses': (context) => const CoursesPage(),
          '/lessons': (context) => const LessonsPage(),
          // '/exam_permission': (context) => const ExamPermissionPage(courseUid: 'courseUid', courseTitle: 'courseTitle',),
          // '/exam': (context) => const ExamPage(courseUid: 'courseUid', courseTitle: 'courseTitle',),
          // '/exam_result': (context) => const ExamResultPage(courseTitle: 'courseTitle',),
        },
      ),
    );
  }
}
