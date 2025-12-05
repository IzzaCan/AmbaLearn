// exam_score_page.dart
import 'package:flutter/material.dart';

class ExamScorePage extends StatelessWidget {
  // Terima hasil skor sebagai argument (placeholder)
  final int correctAnswers;
  final int totalQuestions;

  const ExamScorePage({
    super.key,
    this.correctAnswers = 2, // Placeholder nilai benar
    this.totalQuestions = 3, // Placeholder total soal
  });

  @override
  Widget build(BuildContext context) {
    const Color redTheme = Color(0xFF8B0000);
    final int scorePercentage =
        ((correctAnswers / totalQuestions) * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: redTheme,
        centerTitle: true,
        title: const Text(
          "Exam Result",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () {
            // Kembali ke halaman lessons atau home
            Navigator.popUntil(context, ModalRoute.withName('/lessons'));
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon / Visual Skor
              Icon(
                scorePercentage >= 70 ? Icons.check_circle : Icons.cancel,
                size: 80,
                color: scorePercentage >= 70 ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 20),
              // Judul Hasil
              Text(
                scorePercentage >= 70 ? "Congratulations!" : "Keep Trying!",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Detail Skor
              Text(
                "You scored $correctAnswers out of $totalQuestions questions.",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 30),
              // Lingkaran Skor Persentase
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: redTheme,
                    width: 5,
                  ),
                  color: const Color(0xFF2E2E2E),
                ),
                child: Center(
                  child: Text(
                    "$scorePercentage%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Tombol Kembali
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: redTheme,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Kembali ke halaman lessons
                  Navigator.popUntil(context, ModalRoute.withName('/lessons'));
                },
                child: const Text(
                  "Back to Lessons",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}