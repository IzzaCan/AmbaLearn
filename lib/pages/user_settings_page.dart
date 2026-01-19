// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/auth_provider.dart';
import '../providers/chat_provider.dart';
import '../providers/course_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/language_provider.dart';
import 'loginpage.dart';
import '../l10n/app_localizations.dart';

class UserSettingPage extends StatelessWidget {
  const UserSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final username = auth.user?.username ?? "Guest";
    final email = auth.user?.email ?? "guest@example.com";
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            _buildProfileCard(context, theme, isDark, username, email),

            const SizedBox(height: 32),

            // Appearance Section
            _buildSectionTitle(
              context,
              AppLocalizations.of(context)!.appearance,
            ),
            const SizedBox(height: 12),
            _buildThemeSelector(context, theme, themeProvider),

            const SizedBox(height: 32),

            // Account Section
            _buildSectionTitle(
              context,
              AppLocalizations.of(context)!.account,
            ),
            const SizedBox(height: 12),
            _buildAccountOptions(context, theme),

            const SizedBox(height: 32),

            // Logout Button
            _buildLogoutButton(context, theme, auth),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String username,
    String email,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "G",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Edit Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Edit profile coming soon")),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.textSecondary,
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeData theme,
    ThemeProvider themeProvider,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          _buildThemeOption(
            context: context,
            theme: theme,
            icon: Icons.brightness_auto_rounded,
            title: "System",
            subtitle: "Follow device settings",
            isSelected: themeProvider.themeMode == ThemeModeOption.system,
            onTap: () => themeProvider.setThemeMode(ThemeModeOption.system),
          ),
          Divider(height: 1, color: context.dividerColor),
          _buildThemeOption(
            context: context,
            theme: theme,
            icon: Icons.light_mode_rounded,
            title: "Light",
            subtitle: "Always use light theme",
            isSelected: themeProvider.themeMode == ThemeModeOption.light,
            onTap: () => themeProvider.setThemeMode(ThemeModeOption.light),
          ),
          Divider(height: 1, color: context.dividerColor),
          _buildThemeOption(
            context: context,
            theme: theme,
            icon: Icons.dark_mode_rounded,
            title: "Dark",
            subtitle: "Always use dark theme",
            isSelected: themeProvider.themeMode == ThemeModeOption.dark,
            onTap: () => themeProvider.setThemeMode(ThemeModeOption.dark),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : context.dividerColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isSelected ? theme.colorScheme.primary : context.textSecondary,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: context.textSecondary,
        ),
      ),
      trailing: isSelected
          ? Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 16,
                color: Colors.white,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildAccountOptions(BuildContext context, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dividerColor),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            context: context,
            theme: theme,
            icon: Icons.notifications_outlined,
            title: AppLocalizations.of(context)!.notifications,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Notification settings coming soon"),
                ),
              );
            },
          ),
          _buildSettingItem(
            context: context,
            theme: theme,
            icon: Icons.language_rounded,
            title: AppLocalizations.of(context)!.language,
            trailing: context.watch<LanguageProvider>().isIndonesian
                ? "Indonesia"
                : "English",
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: context.surfaceColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (ctx) => Consumer<LanguageProvider>(
                  builder: (context, langProvider, _) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: context.dividerColor,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Select Language",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ListTile(
                          leading: Text(
                            "🇮🇩",
                            style: theme.textTheme.headlineSmall,
                          ),
                          title: const Text("Bahasa Indonesia"),
                          trailing: langProvider.isIndonesian
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            langProvider.setLanguage('id');
                            Navigator.pop(ctx);
                          },
                        ),
                        ListTile(
                          leading: Text(
                            "🇺🇸",
                            style: theme.textTheme.headlineSmall,
                          ),
                          title: const Text("English"),
                          trailing: !langProvider.isIndonesian
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: theme.colorScheme.primary,
                                )
                              : null,
                          onTap: () {
                            langProvider.setLanguage('en');
                            Navigator.pop(ctx);
                          },
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  },
                ),
              );
            },
          ),
          Divider(height: 1, color: context.dividerColor),
          _buildSettingItem(
            context: context,
            theme: theme,
            icon: Icons.help_outline_rounded,
            title: AppLocalizations.of(context)!.helpSupport,
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Help coming soon")));
            },
          ),
          Divider(height: 1, color: context.dividerColor),
          _buildSettingItem(
            context: context,
            theme: theme,
            icon: Icons.info_outline_rounded,
            title: AppLocalizations.of(context)!.about,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "AmbaLearn",
                applicationVersion: "1.0.0",
                applicationIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.dividerColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: context.textSecondary),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.textSecondary,
              ),
            ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: context.textSecondary),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(
    BuildContext context,
    ThemeData theme,
    AuthProvider auth,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.errorColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon: const Icon(Icons.logout_rounded),
        label: Text(AppLocalizations.of(context)!.logout),
        onPressed: () async {
          // Show confirmation dialog
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(AppLocalizations.of(context)!.logout),
              content: const Text(
                "Are you sure you want to sign out?",
              ), // Can localize this later too
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    AppLocalizations.of(context)!.cancel,
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.errorColor,
                  ),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(
                    AppLocalizations.of(context)!.logout,
                  ),
                ),
              ],
            ),
          );

          if (confirm == true) {
            context.read<ChatProvider>().resetState();
            context.read<CourseProvider>().resetState();
            await auth.logout();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}
