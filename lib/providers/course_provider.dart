import 'package:flutter/material.dart';
import '../models/course_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

/// Unified provider for Course, Lesson, and ChatStep
/// Refactored to match the working web implementation pattern
class CourseProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // COURSE LIST STATE
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _error;

  // CURRENT COURSE DETAIL STATE
  Course? _currentCourse;
  bool _isLoadingDetail = false;

  // GENERATE COURSE STATE
  bool _isGenerating = false;

  // CHAT STEP STATE
  int? _selectedStepNumber;
  int? _activeStepNumber;
  bool _isStepStarted = false;
  List<ChatMessage> _chatMessages = [];
  bool _isSendingMessage = false;
  String? _chatError;

  // GETTERS - Course List
  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // GETTERS - Course Detail
  Course? get currentCourse => _currentCourse;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isGenerating => _isGenerating;

  // GETTERS - Chat Step
  int? get selectedStepNumber => _selectedStepNumber;
  int? get activeStepNumber => _activeStepNumber;
  bool get isStepStarted => _isStepStarted;
  List<ChatMessage> get chatMessages => List.unmodifiable(_chatMessages);
  bool get isSendingMessage => _isSendingMessage;
  String? get chatError => _chatError;

  // COURSE LIST METHODS

  /// Load all courses from API
  Future<void> loadCourses() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.get(ApiConfig.courses);

      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data as List;
        _courses = list
            .map((item) => Course.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _error = "Failed to load courses: $e";
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Generate a new course from topic
  Future<bool> generateCourse(String topic) async {
    if (topic.trim().isEmpty) return false;

    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _api.post(
        ApiConfig.generateCourse,
        data: {"topic": topic.trim()},
      );

      if (response.statusCode == 200 && response.data != null) {
        await loadCourses();
        _isGenerating = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Failed to generate course: $e";
      debugPrint(_error);
    }

    _isGenerating = false;
    notifyListeners();
    return false;
  }

  // COURSE DETAIL METHODS

  /// Load course detail by UID
  Future<bool> loadCourseDetail(String uid) async {
    _isLoadingDetail = true;
    _error = null;
    _currentCourse = null;
    _clearChatStateInternal();
    notifyListeners();

    try {
      final response = await _api.get(ApiConfig.courseDetail(uid));

      if (response.statusCode == 200 && response.data != null) {
        _currentCourse = Course.fromJson(response.data as Map<String, dynamic>);
        _isLoadingDetail = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _error = "Failed to load course detail: $e";
      debugPrint(_error);
    }

    _isLoadingDetail = false;
    notifyListeners();
    return false;
  }

  /// Clear current course
  void clearCurrentCourse() {
    _currentCourse = null;
    _clearChatStateInternal();
    notifyListeners();
  }

  // CHAT STEP METHODS - Following Web Implementation Pattern

  /// Select a step from drawer (no API call yet)
  void selectStep(int stepNumber) {
    _selectedStepNumber = stepNumber;
    _activeStepNumber = null;
    _isStepStarted = false;
    _chatMessages = [];
    _chatError = null;
    notifyListeners();
  }

  /// Load step status and history - EXACTLY like web's lesson_step route
  /// This is the PRIMARY method that should be called when navigating to a step
  Future<bool> loadStepStatus(int stepNumber) async {
    if (_currentCourse == null) return false;

    // Prevent duplicate calls
    if (_isSendingMessage) {
      debugPrint("⚠️ Already loading step, ignoring duplicate");
      return false;
    }

    _activeStepNumber = stepNumber;
    _selectedStepNumber = stepNumber;
    _chatMessages = [];
    _isStepStarted = false;
    _isSendingMessage = true;
    _chatError = null;
    notifyListeners();

    final chatUrl = ApiConfig.courseStepChat(_currentCourse!.uid, stepNumber);

    try {
      debugPrint("📥 GET $chatUrl - Checking step status...");
      final response = await _api.get(chatUrl);

      if (response.statusCode == 200 && response.data != null) {
        // Step is already started - load history
        final history = response.data['history'] as List?;
        if (history != null && history.isNotEmpty) {
          debugPrint(
            "✅ Step already started - loaded ${history.length} messages",
          );
          _chatMessages = history
              .where((m) => m['role'] != 'system')
              .map((m) => ChatMessage.fromJson(m))
              .toList();
          _isStepStarted = true;
          _isSendingMessage = false;
          notifyListeners();
          return true;
        }
      }

      // Step not started yet (404 or empty history)
      debugPrint("ℹ️ Step not started yet - show start button");
      _isStepStarted = false;
      _isSendingMessage = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("📥 GET error (expected for new step): $e");
      // 404 is normal for unstarted steps
      _isStepStarted = false;
      _isSendingMessage = false;
      notifyListeners();
      return true;
    }
  }

  /// Start a new lesson step - Like web's start_lesson route
  /// POST {"start": true} then immediately reload status
  Future<bool> startLessonStep(int stepNumber) async {
    if (_currentCourse == null) return false;

    // Guard against duplicate starts
    if (_isSendingMessage) {
      debugPrint("⚠️ Already starting, ignoring");
      return false;
    }

    _isSendingMessage = true;
    _chatError = null;
    notifyListeners();

    final chatUrl = ApiConfig.courseStepChat(_currentCourse!.uid, stepNumber);

    try {
      // Step 1: POST start (like web's start_lesson POST)
      debugPrint("📤 POST $chatUrl - Starting lesson...");
      await _api.post(chatUrl, data: {"start": true});

      // Don't check POST response - web doesn't either!
      // Just wait a moment for backend to save
      await Future.delayed(const Duration(milliseconds: 1500));
    } catch (e) {
      // Like web version - ignore POST errors, continue to GET
      debugPrint("⚠️ POST error (ignored): $e");
    }

    // Step 2: Reload status (like web's redirect to lesson_step)
    debugPrint("🔄 Reloading step status after start...");
    _isSendingMessage = false;
    notifyListeners();

    return await loadStepStatus(stepNumber);
  }

  /// Send a chat message in current lesson
  Future<bool> sendChatMessage(String message) async {
    final trimmedMessage = message.trim();
    if (_currentCourse == null ||
        _activeStepNumber == null ||
        !_isStepStarted ||
        trimmedMessage.isEmpty) {
      return false;
    }

    // Prevent duplicate sends
    if (_isSendingMessage) {
      debugPrint("⚠️ Already sending, ignoring");
      return false;
    }

    _isSendingMessage = true;
    _chatError = null;

    // Optimistic UI update
    _chatMessages.add(ChatMessage(content: trimmedMessage, isUser: true));
    notifyListeners();

    try {
      final response = await _api.post(
        ApiConfig.courseStepChat(_currentCourse!.uid, _activeStepNumber!),
        data: {"message": trimmedMessage},
      );

      if (response.statusCode == 200 && response.data != null) {
        final reply = response.data['reply'] as String? ?? '';
        if (reply.isNotEmpty) {
          _chatMessages.add(ChatMessage(content: reply, isUser: false));
        }
        _isSendingMessage = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _chatError = "Failed to send message: $e";
      debugPrint(_chatError);
      // Remove optimistic message on failure
      if (_chatMessages.isNotEmpty && _chatMessages.last.isUser) {
        _chatMessages.removeLast();
      }
    }

    _isSendingMessage = false;
    notifyListeners();
    return false;
  }

  /// Submit course feedback
  Future<bool> submitFeedback(String courseUid, String comment) async {
    if (comment.trim().isEmpty) return false;

    try {
      final response = await _api.post(
        ApiConfig.courseFeedback(courseUid),
        data: {"comment": comment.trim()},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (e) {
      debugPrint("Failed to submit feedback: $e");
    }
    return false;
  }

  /// Load existing chat history for a step (GET endpoint)
  /// DEPRECATED - Use loadStepStatus instead
  @Deprecated('Use loadStepStatus instead')
  Future<void> loadStepChatHistory(int stepNumber) async {
    await loadStepStatus(stepNumber);
  }

  /// Clear chat state
  void clearChatState() {
    _clearChatStateInternal();
    notifyListeners();
  }

  /// Internal helper to clear chat state
  void _clearChatStateInternal() {
    _selectedStepNumber = null;
    _activeStepNumber = null;
    _isStepStarted = false;
    _chatMessages = [];
    _isSendingMessage = false;
    _chatError = null;
  }

  // UTILITY METHODS

  /// Clear error
  void clearError() {
    _error = null;
    _chatError = null;
    notifyListeners();
  }

  /// Reset all state (call on logout)
  void resetState() {
    _courses = [];
    _isLoading = false;
    _error = null;
    _currentCourse = null;
    _isLoadingDetail = false;
    _isGenerating = false;
    _activeStepNumber = null;
    _isStepStarted = false;
    _chatMessages = [];
    _isSendingMessage = false;
    _chatError = null;
    notifyListeners();
  }
}
