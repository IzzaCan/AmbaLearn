import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme_config.dart';
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
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.init();

  runApp(AmbaLearn(themeProvider: themeProvider));
}

class AmbaLearn extends StatelessWidget {
  final ThemeProvider themeProvider;

  const AmbaLearn({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: "AmbaLearn",
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.materialThemeMode,
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/home': (context) => const HomePage(),
              '/user_settings': (context) => const UserSettingPage(),
              '/courses': (context) => const CoursesPage(),
              '/lessons': (context) => const LessonsPage(),
            },
          );
        },
      ),
    );
  }
}
