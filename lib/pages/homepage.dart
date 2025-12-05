import 'package:capstone_layout/providers/chat_provider.dart';
import 'package:capstone_layout/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    // Fetch sessions immediately when home loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final username = auth.user?.username ?? "Guest";

    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4D0005),
        title: const Text(
          "AmbaLearn",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),

      // ------------------------------
      // DRAWER
      // ------------------------------
      drawer: AppDrawer(),
      // ------------------------------
      // BODY
      // ------------------------------
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                "Hello, $username!\nMau belajar apa hari ini?",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Input Field + Send Button
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF4D0005),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Tulis disini",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      // TODO: Mic input
                    },
                    icon: const Icon(Icons.mic, color: Color(0xFF870005)),
                  ),
                ),
                const SizedBox(width: 5),
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      // TODO: send message
                    },
                    icon: const Icon(Icons.send, color: Color(0xFF870005)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
