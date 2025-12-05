import 'package:capstone_layout/pages/user_settings_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart'; // Ensure this is imported
import '../pages/chat_page.dart'; // Ensure this is imported

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {

    return Drawer(
      backgroundColor: const Color(0xFF252525),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF4D0005)),
            child: Center(
              child: Text(
                "AmbaLearn Menu",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // New Chat
          ListTile(
            leading: const Icon(Icons.add, color: Colors.white),
            title: const Text(
              "New Chat",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatPage(chatUid: null),
                ),
              );
            },
          ),

          // Courses
          ListTile(
            leading: const Icon(Icons.school, color: Colors.white),
            title: const Text("Courses", style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushNamed(context, '/courses');
            },
          ),

          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
            child: Text(
              "Chats",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Chat history list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, child) {
                if (chatProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (chatProvider.sessions.isEmpty) {
                  return const Center(
                    child: Text(
                      "No chats yet",
                      style: TextStyle(color: Colors.white54),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: chatProvider.sessions.length,
                  itemBuilder: (context, index) {
                    final session = chatProvider.sessions[index];
                    return ListTile(
                      leading: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                      ),
                      title: Text(
                        session.title, // Uses title from backend
                        style: const TextStyle(color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        session.lastModified.split(
                          'T',
                        )[0], // Simple date formatting
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatUid: session.uid,
                            ), // Pass the UID here
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

          const Divider(color: Colors.white24),

          // Profile / Logout
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4D0005),
                minimumSize: const Size.fromHeight(50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserSettingPage()),
                );
              },
              icon: const Icon(Icons.person),
              label: const Text(
                "Profile",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
