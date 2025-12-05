// lessons.dart (Kode Full dengan Perubahan Lokasi Element)
import 'package:capstone_layout/pages/exampage.dart';
import 'package:capstone_layout/pages/homepage.dart';
import 'package:capstone_layout/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';

class LessonsPage extends StatefulWidget {
  const LessonsPage({super.key});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  bool hasStarted = false; // controls if lesson has started
  final TextEditingController _messageController = TextEditingController();

  String currentLesson = "Ready to start your lesson?";

  // Tambahkan list untuk menyimpan pesan chat dan elemen lain (seperti video)
  final List<Map<String, dynamic>> _chatMessages = [];

  // Example lesson list
  final List<String> lessons = [
    "Lesson 1: Introduction",
    "Lesson 2: Concepts",
    "Lesson 3: Practice",
    "Lesson 4: Summary",
  ];
  // Example hint questions for each lesson
  final Map<String, List<String>> hintQuestions = {
    "Lesson 1: Introduction": [
      "Apa tujuan dari materi ini?",
      "Kenapa topik ini penting?",
      "Bisakah jelaskan konsepnya secara sederhana?",
    ],
    "Lesson 2: Concepts": [
      "Apa istilah penting di lesson ini?",
      "Bagaimana konsep ini bekerja?",
      "Apa perbedaan konsep A dan B?",
    ],
    "Lesson 3: Practice": [
      "Bisa beri saya soal latihan?",
      "Bagaimana langkah-langkah penyelesaiannya?",
      "Apa kesalahan umum yang harus dihindari?",
    ],
    "Lesson 4: Summary": [
      "Apa poin penting yang harus diingat?",
      "Bisa rangkum materi ini?",
      "Bagaimana saya menerapkan konsep ini?",
    ],
  };

  // Widget terpisah untuk Placeholder Rekomendasi Video
  Widget _buildVideoRecommendation(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF333333), // Dark Grey
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder Image
            Container(
              width: 80,
              height: 50,
              color: const Color.fromARGB(255, 77, 0, 5),
              child: const Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 10),
            // Video Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Rekomendasi Video",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigasi ke pelajaran baru
  void _changeLesson(String lessonTitle) {
    setState(() {
      currentLesson = lessonTitle;
      // Hapus pesan lama dan tambahkan pesan AI baru
      _chatMessages.clear();
      _chatMessages.add({
        "type": "text",
        "message":
            "Kita akan bahas **$lessonTitle**. Ini adalah pelajaran penting untuk memahami ...",
        "isUser": false,
      });
      _chatMessages.add({
        "type": "video",
        "title": "Regresi Linear untuk Pemula (Full Course)",
      });
    });
    Navigator.pop(context);
  }

  // Mengirim pesan (placeholder)
  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        _chatMessages.insert(0, {
          "type": "text",
          "message": _messageController.text,
          "isUser": true,
        });
      });
      _messageController.clear();
      // TODO: Implement AI response logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    // Receive course name from navigation argument
    final String courseTitle =
        ModalRoute.of(context)?.settings.arguments as String? ?? "Course";

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 37, 37, 37),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 77, 0, 5),
        title: Text(
          courseTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      // Sidebar Drawer for Lessons (Sama seperti sebelumnya)
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 37, 37, 37),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color.fromARGB(255, 77, 0, 5)),
              child: Center(
                child: Text(
                  "AmbaLearn Lessons",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back, color: Colors.white),
              title: const Text(
                "Back to Home",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Homepage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
                    child: Text(
                      "Lessons",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...lessons.map((lesson) {
                    return ListTile(
                      leading: const Icon(
                        Icons.menu_book_outlined,
                        color: Colors.white,
                      ),
                      title: Text(
                        lesson,
                        style: const TextStyle(color: Colors.white),
                      ),
                      onTap: () => _changeLesson(lesson),
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 15, bottom: 5),
                    child: Text(
                      "Exam",
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.quiz_outlined,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Final Exam",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ExamPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: hasStarted
                ? ListView.builder(
                    reverse: true, // Untuk chat terbaru di bawah
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: _chatMessages.length,
                    itemBuilder: (context, index) {
                      // Ambil index dari belakang karena reverse: true
                      final chat =
                          _chatMessages[_chatMessages.length - 1 - index];

                      if (chat["type"] == "video") {
                        return _buildVideoRecommendation(chat["title"]);
                      }

                      return ChatBubble(
                        message: chat["message"],
                        isUser: chat["isUser"],
                      );
                    },
                  )
                : Center(
                    // Area sebelum Start ditekan
                    child: Text(
                      currentLesson,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),

          // ========================= INPUT SECTION CONTAINER =========================
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color.fromARGB(255, 77, 0, 5),
            child: hasStarted
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. HORIZONTAL HINT QUESTIONS (DIPINDAHKAN KE SINI)
                      Container(
                        height: 50,
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              (hintQuestions[currentLesson] ?? []).length,
                          itemBuilder: (context, index) {
                            final question =
                                (hintQuestions[currentLesson] ?? [])[index];
                            return Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.13),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                question,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // 2. INPUT BAR (TEXTFIELD + BUTTONS)
                      Row(
                        children: [
                          // TEXTFIELD
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              onSubmitted: (value) => _sendMessage(),
                              decoration: InputDecoration(
                                hintText: "Type your message...",
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

                          // MIC BUTTON
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              onPressed: () {
                                // TODO: handle mic input
                              },
                              icon: const Icon(
                                Icons.mic,
                                color: Color.fromARGB(255, 135, 0, 5),
                              ),
                            ),
                          ),

                          const SizedBox(width: 5),

                          // SEND BUTTON
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: IconButton(
                              onPressed: _sendMessage,
                              icon: const Icon(
                                Icons.send,
                                color: Color.fromARGB(255, 135, 0, 5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    // Tombol Start
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 200, 80, 80),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          hasStarted = true;
                          currentLesson = lessons.first;
                          // TAMBAHKAN PESAN AWAL AI DAN VIDEO
                          _chatMessages.add({
                            "type": "video",
                            "title":
                                "Regresi Linear untuk Pemula (Full Course)",
                          });
                          _chatMessages.add({
                            "type": "text",
                            "message":
                                "Halo! Saya adalah AI Tutor Anda. Kita akan mulai dengan **Lesson 1: Introduction**. Materi ini menjelaskan dasar-dasar regresi linier. ...",
                            "isUser": false,
                          });
                        });
                      },
                      child: const Text(
                        "Start",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
