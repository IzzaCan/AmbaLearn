import 'package:flutter/material.dart';
import '../models/chat_session_model.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<ChatSession> _sessions = [];
  bool _isLoading = false;

  List<ChatSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> loadSessions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _api.get(ApiConfig.listSessions);
      
      if (response.statusCode == 200 && response.data != null) {
        final List list = response.data['sessions'] ?? [];
        _sessions = list.map((item) => ChatSession.fromJson(item)).toList();
      }
    } catch (e) {
      print("Error loading sessions: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}