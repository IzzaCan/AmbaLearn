import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'loginpage.dart';

class UserSettingPage extends StatelessWidget {
  const UserSettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final username = auth.user?.username ?? "Guest";
    final email = auth.user?.email ?? "guest@example.com";

    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        title: const Text(
          "User Settings",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4D0005),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(
                username,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(email, style: const TextStyle(color: Colors.white)),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                await auth.logout(); // logout Google jika login pakai Google
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
