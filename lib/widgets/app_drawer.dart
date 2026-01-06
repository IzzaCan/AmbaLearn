import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../pages/user_settings_page.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Drawer(
      backgroundColor: const Color(0xFF252525),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4D0005)),
            child: Center(
              child: Text(
                "AmbaLearn",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // ===== NEW CHAT (DRAFT RESET) =====
          ListTile(
            leading: const Icon(Icons.add, color: Colors.white),
            title: const Text(
              "New Chat",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              chat.startNewChat(); // ✅ draft only
            },
          ),

          // ===== OTHER MENU =====
          ListTile(
            leading: const Icon(Icons.school, color: Colors.white),
            title: const Text(
              "Courses",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/courses');
            },
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Text(
              "Chats",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // ===== CHAT LIST =====
          Expanded(
            child: chat.isLoadingSessions
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : chat.sessions.isEmpty
                    ? const Center(
                        child: Text(
                          "No chats yet",
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        itemCount: chat.sessions.length,
                        itemBuilder: (context, index) {
                          final session = chat.sessions[index];
                          final bool isActive =
                              session.uid == chat.currentSessionUid;

                          return ListTile(
                            leading: Icon(
                              Icons.chat_bubble_outline,
                              color: isActive
                                  ? Colors.orangeAccent
                                  : Colors.white,
                            ),
                            title: Text(
                              session.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: isActive
                                    ? Colors.orangeAccent
                                    : Colors.white,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(
                              session.lastModified.split('T').first,
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);

                              if (session.uid !=
                                  chat.currentSessionUid) {
                                chat.loadSession(session.uid);
                              }
                            },
                          );
                        },
                      ),
          ),

          const Divider(color: Colors.white24),

          // ===== PROFILE =====
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D0005),
                minimumSize: const Size.fromHeight(48),
              ),
              icon: const Icon(Icons.person, color: Colors.white),
              label: const Text(
                "Profile",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UserSettingPage(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
