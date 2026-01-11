import 'package:flutter/material.dart';
import '../models/exam_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

/// ExamProvider - Manages exam state and API interactions
/// Follows the same pattern as CourseProvider
class ExamProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // EXAM STATE
  Exam? _currentExam;
  String? _examUid;
  String? _courseUid;
  bool _isLoadingExam = false;
  bool _isSubmitting = false;
  String? _error;

  // USER ANSWERS STATE
  final UserAnswers _userAnswers = UserAnswers();
  int _currentQuestionIndex = 0;

  // RESULT STATE
  ExamResult? _examResult;

  // CAMERA PERMISSION STATE
  bool _cameraPermissionGranted = false;

  // GETTERS - Exam
  Exam? get currentExam => _currentExam;
  String? get examUid => _examUid;
  String? get courseUid => _courseUid;
  bool get isLoadingExam => _isLoadingExam;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;

  // GETTERS - Answers
  UserAnswers get userAnswers => _userAnswers;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get totalQuestions => _currentExam?.totalQuestions ?? 0;
  int get answeredCount => _userAnswers.answeredCount;
  bool get isAllAnswered =>
      answeredCount >= totalQuestions && totalQuestions > 0;

  // GETTERS - Result
  ExamResult? get examResult => _examResult;

  // GETTERS - Camera
  bool get cameraPermissionGranted => _cameraPermissionGranted;

  // EXAM LOADING METHODS

  /// Load or generate exam for a course
  /// Following the web pattern: GET /course/<uid>/exam
  Future<bool> loadExam(String courseUid) async {
    if (_isLoadingExam) {
      debugPrint("⚠️ Already loading exam, ignoring duplicate call");
      return false;
    }

    _courseUid = courseUid;
    _isLoadingExam = true;
    _error = null;
    _currentExam = null;
    _examUid = null;
    notifyListeners();

    try {
      debugPrint("📥 GET ${ApiConfig.courseExam(courseUid)} - Loading exam...");
      final response = await _api.get(ApiConfig.courseExam(courseUid));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        _examUid = data['exam_uid'] as String?;
        final examData = data['exam'] as Map<String, dynamic>?;

        if (examData != null) {
          _currentExam = Exam.fromJson(examData);
          debugPrint(
            "✅ Exam loaded: ${_currentExam!.totalQuestions} questions",
          );
          _isLoadingExam = false;
          notifyListeners();
          return true;
        }
      }

      _error = "Failed to load exam";
      debugPrint("❌ Failed to load exam: ${response.statusCode}");
    } catch (e) {
      _error = "Error loading exam: $e";
      debugPrint("❌ Error loading exam: $e");
    }

    _isLoadingExam = false;
    notifyListeners();
    return false;
  }

  // ANSWER MANAGEMENT

  /// Set answer for a question
  void setAnswer(int questionIndex, String answer) {
    _userAnswers.setAnswer(questionIndex, answer);
    debugPrint("✏️ Question ${questionIndex + 1} answered: $answer");
    notifyListeners();
  }

  /// Get answer for a question
  String? getAnswer(int questionIndex) {
    return _userAnswers.getAnswer(questionIndex);
  }

  /// Navigate to specific question
  void goToQuestion(int index) {
    if (index >= 0 && index < totalQuestions) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  /// Go to next question
  void nextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Go to previous question
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  // SUBMISSION

  /// Submit exam answers
  /// POST /course/<uid>/exam/submit
  Future<bool> submitExam() async {
    if (_courseUid == null || _examUid == null || _currentExam == null) {
      _error = "Exam not loaded properly";
      notifyListeners();
      return false;
    }

    if (_isSubmitting) {
      debugPrint("⚠️ Already submitting, ignoring duplicate call");
      return false;
    }

    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint(
        "📤 POST ${ApiConfig.submitCourseExam(_courseUid!)} - Submitting exam...",
      );
      debugPrint("📤 Answers: ${_userAnswers.toJson()}");

      final response = await _api.post(
        ApiConfig.submitCourseExam(_courseUid!),
        data: {"exam_uid": _examUid, "answers": _userAnswers.toJson()},
      );

      if (response.statusCode == 200 && response.data != null) {
        _examResult = ExamResult.fromJson(
          response.data as Map<String, dynamic>,
        );
        debugPrint("✅ Exam submitted: Score ${_examResult!.score}%");
        _isSubmitting = false;
        notifyListeners();
        return true;
      }

      _error = "Failed to submit exam";
      debugPrint("❌ Submit failed: ${response.statusCode}");
    } catch (e) {
      _error = "Error submitting exam: $e";
      debugPrint("❌ Error submitting: $e");
    }

    _isSubmitting = false;
    notifyListeners();
    return false;
  }

  // CAMERA PERMISSION

  /// Set camera permission status
  void setCameraPermission(bool granted) {
    _cameraPermissionGranted = granted;
    notifyListeners();
  }

  // UTILITY METHODS

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset exam state (when leaving exam)
  void resetExamState() {
    _currentExam = null;
    _examUid = null;
    _courseUid = null;
    _userAnswers.clear();
    _currentQuestionIndex = 0;
    _examResult = null;
    _error = null;
    _cameraPermissionGranted = false;
    notifyListeners();
  }

  /// Check if exam can be submitted
  bool canSubmit() {
    return _currentExam != null && _examUid != null && !_isSubmitting;
  }

  /// Get progress percentage
  double get progressPercentage {
    if (totalQuestions == 0) return 0.0;
    return (answeredCount / totalQuestions);
  }
}
