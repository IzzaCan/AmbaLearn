import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../models/exam_model.dart';

/// ExamResultPage - Display exam results
/// Matches the web version's score.html pattern
class ExamResultPage extends StatelessWidget {
  final String courseTitle;

  const ExamResultPage({super.key, required this.courseTitle});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Clear exam state when leaving
        context.read<ExamProvider>().resetExamState();
        return true;
      },
      child: Consumer<ExamProvider>(
        builder: (context, provider, child) {
          final result = provider.examResult;

          if (result == null) {
            return _buildErrorScreen(context);
          }

          return Scaffold(
            backgroundColor: const Color(0xFF252525),
            appBar: AppBar(
              backgroundColor: const Color(0xFF4D0005),
              title: const Text(
                'Exam Results',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildScoreCard(result),
                  const SizedBox(height: 32),
                  _buildGradeSection(result),
                  const SizedBox(height: 32),
                  _buildStatistics(result),
                  const SizedBox(height: 32),
                  _buildDetailedResults(result),
                  const SizedBox(height: 32),
                  _buildActionButtons(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF252525),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'No exam results found',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreCard(ExamResult result) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: result.isPassing
              ? [const Color(0xFF4CAF50), const Color(0xFF45a049)]
              : [const Color(0xFFC85050), const Color(0xFF4D0005)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (result.isPassing ? Colors.green : Colors.red).withOpacity(
              0.3,
            ),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            courseTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your Score',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${result.score}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 72,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              result.isPassing ? 'PASSED' : 'FAILED',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradeSection(ExamResult result) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF4D0005).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGradeItem('Grade', result.grade, Icons.star),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildGradeItem(
            'Correct',
            '${result.correctCount}/${result.totalQuestions}',
            Icons.check_circle,
          ),
        ],
      ),
    );
  }

  Widget _buildGradeItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.orangeAccent, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatistics(ExamResult result) {
    final incorrectCount = result.totalQuestions - result.correctCount;
    final accuracy = result.totalQuestions > 0
        ? (result.correctCount / result.totalQuestions * 100)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF4D0005).withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              _buildStatRow(
                'Total Questions',
                result.totalQuestions.toString(),
                Icons.quiz,
              ),
              const Divider(color: Colors.white12, height: 24),
              _buildStatRow(
                'Correct Answers',
                result.correctCount.toString(),
                Icons.check_circle_outline,
                color: Colors.green,
              ),
              const Divider(color: Colors.white12, height: 24),
              _buildStatRow(
                'Incorrect Answers',
                incorrectCount.toString(),
                Icons.cancel_outlined,
                color: Colors.red,
              ),
              const Divider(color: Colors.white12, height: 24),
              _buildStatRow(
                'Accuracy',
                '${accuracy.toStringAsFixed(1)}%',
                Icons.percent,
                color: Colors.orangeAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color ?? Colors.white54, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedResults(ExamResult result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Question Details',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...result.details.asMap().entries.map((entry) {
          final index = entry.key;
          final detail = entry.value;
          return _buildQuestionDetail(index + 1, detail);
        }).toList(),
      ],
    );
  }

  Widget _buildQuestionDetail(int questionNumber, QuestionResult detail) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: detail.isCorrect
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: detail.isCorrect ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: detail.isCorrect ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$questionNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      detail.isCorrect ? Icons.check_circle : Icons.cancel,
                      color: detail.isCorrect ? Colors.green : Colors.red,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      detail.isCorrect ? 'Correct' : 'Incorrect',
                      style: TextStyle(
                        color: detail.isCorrect ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (!detail.isCorrect) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Your answer: ${detail.userAnswer ?? "Not answered"}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    'Correct answer: ${detail.correctAnswer}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<ExamProvider>().resetExamState();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC85050),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.home),
            label: const Text(
              'Back to Home',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<ExamProvider>().resetExamState();
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back to Course', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
