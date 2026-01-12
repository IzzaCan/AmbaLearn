// exam_score_page.dart
import 'package:flutter/material.dart';
import '../config/theme_config.dart';

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
    final theme = Theme.of(context);
    final int scorePercentage = ((correctAnswers / totalQuestions) * 100)
        .toInt();
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isPassing = scorePercentage >= 70;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Exam Result",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            // Kembali ke halaman lessons atau home
            Navigator.popUntil(context, ModalRoute.withName('/lessons'));
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(32, 32, 32, 32 + bottomPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Ikon / Visual Skor
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isPassing
                      ? context.successColor.withOpacity(0.2)
                      : context.errorColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPassing ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  size: 80,
                  color: isPassing ? context.successColor : context.errorColor,
                ),
              ),
              const SizedBox(height: 20),
              // Judul Hasil
              Text(
                isPassing ? "Congratulations!" : "Keep Trying!",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Detail Skor
              Text(
                "You scored $correctAnswers out of $totalQuestions questions.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: context.textSecondary,
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
                    color: theme.colorScheme.primary,
                    width: 5,
                  ),
                  color: context.surfaceColor,
                ),
                child: Center(
                  child: Text(
                    "$scorePercentage%",
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Tombol Kembali
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // Kembali ke halaman lessons
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName('/lessons'),
                    );
                  },
                  child: const Text(
                    "Back to Lessons",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
