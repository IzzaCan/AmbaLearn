import 'package:flutter/material.dart';
import '../models/chat_session_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  // Sidebar sessions
  List<ChatSession> _sessions = [];
  bool _isLoadingSessions = false;

  // Active chat
  String? _currentSessionUid; // null = draft
  final List<Map<String, dynamic>> _messages = [];

  bool _isChatLoading = false;
  bool _isSending = false;
  String? _error;

  // ===== Getters =====
  List<ChatSession> get sessions => _sessions;
  bool get isLoadingSessions => _isLoadingSessions;

  String? get currentSessionUid => _currentSessionUid;
  List<Map<String, dynamic>> get messages => _messages;

  bool get isChatLoading => _isChatLoading;
  bool get isSending => _isSending;
  String? get error => _error;

  bool get isDraft => _currentSessionUid == null;

  // =========================
  // Sidebar: Load chat list
  // =========================
  Future<void> loadSessions() async {
    _isLoadingSessions = true;
    notifyListeners();

    try {
      final res = await _api.get(ApiConfig.listSessions);
      if (res.statusCode == 200 && res.data != null) {
        final List list = res.data['sessions'] ?? [];
        _sessions = list.map((e) => ChatSession.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint("Load sessions error: $e");
    } finally {
      _isLoadingSessions = false;
      notifyListeners();
    }
  }

  // =========================
  // Load existing chat
  // =========================
  Future<void> loadSession(String uid) async {
    _isChatLoading = true;
    _error = null;
    _currentSessionUid = uid;
    _messages.clear();
    notifyListeners();

    try {
      final res = await _api.get(ApiConfig.getSession(uid));
      if (res.statusCode == 200 && res.data != null) {
        final List history = res.data['messages'] ?? [];
        _messages.addAll(
          history
              .where((m) => m['role'] != 'system')
              .map((m) => m as Map<String, dynamic>),
        );
      }
    } catch (e) {
      _error = "Failed to load chat";
    } finally {
      _isChatLoading = false;
      notifyListeners();
    }
  }

  // =========================
  // SEND MESSAGE (CORE LOGIC)
  // =========================
  Future<void> sendMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty || _isSending) return;

    _error = null;

    // 1️⃣ Add user message to UI
    _messages.add({"role": "user", "content": content});
    _isSending = true;
    notifyListeners();

    try {
      // 2️⃣ Create session ONLY if draft
      if (_currentSessionUid == null) {
        final createRes = await _api.post(ApiConfig.createSession);

        if (createRes.statusCode != 200) {
          throw Exception("Failed to create session");
        }
        _currentSessionUid = createRes.data['uid'];

        // refresh sidebar once
        loadSessions();
      }

      // 3️⃣ Send message to backend
      final res = await _api.post(
        ApiConfig.chat,
        data: {"uid": _currentSessionUid, "message": content},
      );

      if (res.statusCode == 200 && res.data != null) {
        _messages.add({"role": "assistant", "content": res.data['reply']});
      } else {
        throw Exception("Invalid response from server");
      }
    } catch (e) {
      _error = "Failed to send message";
      debugPrint("ChatProvider Error: $e");
      _messages.removeLast(); // rollback user msg
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // =========================
  // New Chat (Draft Reset)
  // =========================
  void startNewChat() {
    _currentSessionUid = null;
    _messages.clear();
    _error = null;
    notifyListeners();
  }

  // =========================
  // Error handling
  // =========================
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // =========================
  // Logout cleanup
  // =========================
  void resetState() {
    _sessions.clear();
    _currentSessionUid = null;
    _messages.clear();
    _isLoadingSessions = false;
    _isChatLoading = false;
    _isSending = false;
    _error = null;
    notifyListeners();
  }
}
