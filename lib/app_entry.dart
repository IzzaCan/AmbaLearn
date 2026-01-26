import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'pages/loginpage.dart';
import 'pages/birthday_onboarding_page.dart';
import 'pages/homepage.dart';

class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    /// 1. Belum login
    if (!authProvider.isLoggedIn) {
      return const LoginPage();
    }

    /// 2. Sudah login tapi data user belum siap
    if (authProvider.isLoading || authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    /// 3. Wajib onboarding jika birthday kosong
    if (authProvider.user!.birthday == null) {
      return const OnboardingBirthdayPage();
    }

    /// 4. Semua syarat terpenuhi
    return const HomePage();
  }
}