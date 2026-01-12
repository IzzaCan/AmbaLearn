/// Exam Model - Represents exam data structure
class Exam {
  final String examTitle;
  final List<ExamQuestion> questions;

  Exam({required this.examTitle, required this.questions});

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      examTitle: json['exam_title'] as String? ?? 'Untitled Exam',
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => ExamQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exam_title': examTitle,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  int get totalQuestions => questions.length;
}

/// Individual exam question
class ExamQuestion {
  final String question;
  final Map<String, String> options; // A, B, C, D, E
  final String answer; // Correct answer (A-E)

  ExamQuestion({
    required this.question,
    required this.options,
    required this.answer,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    // Handle options - backend returns as Map<String, String>
    final optionsData = json['options'] as Map<String, dynamic>?;
    final Map<String, String> parsedOptions = {};

    if (optionsData != null) {
      optionsData.forEach((key, value) {
        parsedOptions[key] = value.toString();
      });
    }

    return ExamQuestion(
      question: json['question'] as String? ?? '',
      options: parsedOptions,
      answer: json['answer'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'question': question, 'options': options, 'answer': answer};
  }

  /// Get sorted option keys (A, B, C, D, E)
  List<String> get sortedOptionKeys {
    final keys = options.keys.toList();
    keys.sort();
    return keys;
  }
}

/// Exam submission result
class ExamResult {
  final int score; // Percentage (0-100)
  final int totalQuestions;
  final int correctCount;
  final List<QuestionResult> details;

  ExamResult({
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.details,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      score: json['score'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? 0,
      correctCount: json['correct_count'] as int? ?? 0,
      details:
          (json['detail'] as List<dynamic>?)
              ?.map((d) => QuestionResult.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  double get percentage => totalQuestions > 0 ? (score / 100) * 100 : 0;

  bool get isPassing => score >= 70; // 70% to pass

  String get grade {
    if (score >= 90) return 'A';
    if (score >= 80) return 'B';
    if (score >= 70) return 'C';
    if (score >= 60) return 'D';
    return 'F';
  }
}

/// Individual question result
class QuestionResult {
  final int questionIndex;
  final String? userAnswer;
  final String correctAnswer;
  final bool isCorrect;

  QuestionResult({
    required this.questionIndex,
    this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
  });

  factory QuestionResult.fromJson(Map<String, dynamic> json) {
    return QuestionResult(
      questionIndex: json['question_index'] as int? ?? 0,
      userAnswer: json['user_answer'] as String?,
      correctAnswer: json['correct_answer'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }
}

/// User's answer state (for UI tracking)
class UserAnswers {
  final Map<String, String> _answers = {}; // q1 -> A, q2 -> B, etc.

  void setAnswer(int questionIndex, String answer) {
    _answers['q${questionIndex + 1}'] = answer;
  }

  String? getAnswer(int questionIndex) {
    return _answers['q${questionIndex + 1}'];
  }

  Map<String, String> toJson() => Map.from(_answers);

  int get answeredCount => _answers.length;

  bool isAnswered(int questionIndex) {
    return _answers.containsKey('q${questionIndex + 1}');
  }

  void clear() {
    _answers.clear();
  }
}
