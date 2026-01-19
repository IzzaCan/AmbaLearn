// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/auth_provider.dart';

import 'loginpage.dart';
import '../l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController userC = TextEditingController();
  final TextEditingController emailC = TextEditingController();
  final TextEditingController passC = TextEditingController();
  bool obscure = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    userC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    AppColors.darkBackground,
                    AppColors.darkSurface,
                    AppColors.darkAccent.withOpacity(0.2),
                  ]
                : [
                    AppColors.lightBackground,
                    AppColors.lightSurface,
                    AppColors.lightAccent.withOpacity(0.1),
                  ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    _buildHeader(theme, isDark),
                    const SizedBox(height: 40),

                    // Register Card
                    _buildRegisterCard(theme, isDark, auth),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      children: [
        // App Icon with glow effect
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.secondary, theme.colorScheme.primary],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.secondary.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.person_add_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          AppLocalizations.of(context)!.createAccount,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.signUpStarted,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterCard(ThemeData theme, bool isDark, AuthProvider auth) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withOpacity(0.8)
                  : AppColors.lightSurface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Username Input
                TextField(
                  controller: userC,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: context.textSecondary,
                    ),
                    labelText: AppLocalizations.of(context)!.username,
                    hintText: AppLocalizations.of(context)!.enterUsername,
                  ),
                ),
                const SizedBox(height: 20),

                // Email Input
                TextField(
                  controller: emailC,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: context.textSecondary,
                    ),
                    labelText: AppLocalizations.of(context)!.email,
                    hintText: AppLocalizations.of(context)!.enterEmail,
                  ),
                ),
                const SizedBox(height: 20),

                // Password Input
                TextField(
                  controller: passC,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: context.textSecondary,
                    ),
                    labelText: AppLocalizations.of(context)!.password,
                    hintText: AppLocalizations.of(context)!.enterPassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => obscure = !obscure),
                      icon: Icon(
                        obscure ? Icons.visibility_off : Icons.visibility,
                        color: context.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Register Button
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                    onPressed: auth.isLoading
                        ? null
                        : () async {
                            final res = await auth.register(
                              userC.text,
                              emailC.text,
                              passC.text,
                            );
                            if (!mounted) return;
                            if (res != null) {
                              ScaffoldMessenger.of(
                                context,
                              ).showSnackBar(SnackBar(content: Text(res)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    "Registration successful!",
                                  ),
                                  backgroundColor: context.successColor,
                                ),
                              );
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginPage(),
                                ),
                              );
                            }
                          },
                    child: auth.isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: theme.colorScheme.onSecondary,
                            ),
                          )
                        : Text(AppLocalizations.of(context)!.createAccount),
                  ),
                ),
                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${AppLocalizations.of(context)!.alreadyAccount} ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.signIn,
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
