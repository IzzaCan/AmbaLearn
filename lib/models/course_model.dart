class Course {
  final String uid;
  final String courseTitle;
  final String description;
  final String difficulty;
  final List<CourseStep> steps;

  Course({
    required this.uid,
    required this.courseTitle,
    required this.description,
    required this.difficulty,
    required this.steps,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      uid: json['uid'] as String? ?? '',
      courseTitle: json['course_title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map((e) => CourseStep.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class CourseStep {
  final int stepNumber;
  final String title;

  CourseStep({required this.stepNumber, required this.title});

  factory CourseStep.fromJson(Map<String, dynamic> json) {
    return CourseStep(
      stepNumber: json['step_number'] as int? ?? 0,
      title: json['title'] as String? ?? '',
    );
  }
}

/// Represents a chat message in a lesson step
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Factory to parse from backend response
  /// Backend returns: {"role": "user"|"assistant"|"system", "content": "..."}
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final role = json['role'] as String?;
    return ChatMessage(
      content: json['content'] as String? ?? '',
      isUser: role == 'user',
    );
  }
}
