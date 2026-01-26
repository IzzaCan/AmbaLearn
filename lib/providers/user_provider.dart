import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';

class UserProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ===== UPDATE USER PROFILE =====
  Future<String?> updateUser({
    String? username,
    String? birthday, // format: YYYY-MM-DD
    String? password,
  }) async {
    _setLoading(true);
    try {
      final Map<String, dynamic> data = {};

      if (username != null) data['username'] = username;
      if (birthday != null) data['birthday'] = birthday;
      if (password != null) data['password'] = password;

      if (data.isEmpty) {
        return "Tidak ada data yang diperbarui";
      }

      final res = await _api.post(ApiConfig.updateUser, data: data);

      if (res.statusCode == 200) {
        return null;
      }

      return res.data?['error'] ?? "Gagal memperbarui data";
    } catch (e) {
      return "Terjadi kesalahan: $e";
    } finally {
      _setLoading(false);
    }
  }
}
