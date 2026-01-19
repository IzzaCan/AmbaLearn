import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
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
import 'providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  final languageProvider = LanguageProvider();
  await languageProvider.init();

  runApp(
    AmbaLearn(themeProvider: themeProvider, languageProvider: languageProvider),
  );
}

class AmbaLearn extends StatelessWidget {
  final ThemeProvider themeProvider;
  final LanguageProvider languageProvider;

  const AmbaLearn({
    super.key,
    required this.themeProvider,
    required this.languageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: languageProvider),
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
            
            // Localization
            locale: Provider.of<LanguageProvider>(context).locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('id'),
            ],

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
