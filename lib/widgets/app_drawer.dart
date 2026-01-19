import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme_config.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../pages/user_settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final theme = Theme.of(context);
    final isDark = context.isDarkMode;

    return Drawer(
      backgroundColor: context.surfaceColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          _buildHeader(context, theme),

          // ===== NEW CHAT =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text("New Chat"),
                onPressed: () {
                  Navigator.pop(context);
                  chat.startNewChat();
                },
              ),
            ),
          ),


          const SizedBox(height: 8),

          // ===== MENU =====
          _buildMenuItem(
            context: context,
            icon: Icons.school_rounded,
            title: "Courses",
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/courses');
            },
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Text(
              "RECENT CHATS",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // ===== CHAT LIST =====
          Expanded(
            child: chat.isLoadingSessions
                ? Center(
                    child: CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                  )
                : chat.sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48,
                          color: context.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No chats yet",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: chat.sessions.length,
                    itemBuilder: (context, index) {
                      final session = chat.sessions[index];
                      final bool isActive =
                          session.uid == chat.currentSessionUid;

                      return _buildChatItem(
                        context: context,
                        title: session.title,
                        subtitle: session.lastModified.split('T').first,
                        isActive: isActive,
                        onTap: () {
                          Navigator.pop(context);
                          if (session.uid != chat.currentSessionUid) {
                            chat.loadSession(session.uid);
                          }
                        },
                      );
                    },
                  ),
          ),

          Divider(color: context.dividerColor),

          // ===== THEME TOGGLE =====
          _buildThemeToggle(context, theme),

          // ===== PROFILE =====
          _buildProfileSection(context, theme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_rounded,
              size: 28,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "AmbaLearn",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Learn Smarter",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: theme.textTheme.titleSmall),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: context.textSecondary,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildChatItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.secondary.withOpacity(0.2)
                : context.dividerColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 18,
            color: isActive
                ? theme.colorScheme.secondary
                : context.textSecondary,
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? theme.colorScheme.secondary : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.textSecondary,
          ),
        ),
        dense: true,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isActive
            ? theme.colorScheme.secondary.withOpacity(0.1)
            : null,
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeData theme) {
    final themeProvider = context.watch<ThemeProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            themeProvider.themeModeIcon,
            size: 20,
            color: theme.colorScheme.secondary,
          ),
        ),
        title: Text("Theme", style: theme.textTheme.titleSmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            themeProvider.themeModeDisplayName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () => themeProvider.cycleThemeMode(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ThemeData theme) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 12 + bottomPadding),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white),
        ),
        title: Text(
          "Profile",
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          "View settings",
          style: theme.textTheme.bodySmall?.copyWith(
            color: context.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: context.textSecondary,
        ),
        onTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserSettingPage()),
          );
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: context.isDarkMode
            ? AppColors.darkBackground
            : AppColors.lightBackground,
      ),
    );
  }
}
