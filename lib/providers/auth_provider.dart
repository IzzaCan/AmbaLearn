import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;

  final ApiService _api = ApiService();

  // Helper: Set Loading
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // VALIDATION
  String? validateEmail(String email) {
    if (email.isEmpty) return "Email wajib diisi";
    if (!email.contains('@')) return "Email tidak valid";
    return null;
  }

  String? validatePassword(String password) {
    if (password.isEmpty) return "Password wajib diisi";
    //if (password.length < 6) return "Password minimal 6 karakter";
    return null;
  }

  String? validateUsername(String username) {
    if (username.isEmpty) return "Username wajib diisi";
    return null;
  }

  // REGISTER EMAIL/PASSWORD
  Future<String?> register(
    String username,
    String email,
    String password,
  ) async {
    // Validasi dulu sebelum request
    final usernameError = validateUsername(username);
    if (usernameError != null) return usernameError;

    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    _setLoading(true);
    try {
      final res = await _api.post(
        ApiConfig.register,
        data: {'username': username, 'email': email, 'password': password},
      );

      // Accept 200 or 201 as success
      if (res.statusCode == 200 || res.statusCode == 201) {
        // Bisa langsung fetch user setelah register
        await fetchCurrentUser();
        return null;
      }

      // Backend error message (jika ada)
      if (res.data != null && res.data['error'] != null) {
        return res.data['error'];
      }

      return "Registrasi gagal: ${res.statusCode}";
    } catch (e) {
      return "Terjadi kesalahan: $e";
    } finally {
      _setLoading(false);
    }
  }

  // LOGIN EMAIL/PASSWORD
  Future<String?> login(String email, String password) async {
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    _setLoading(true);
    try {
      final res = await _api.post(
        ApiConfig.login,
        data: {"email": email, "password": password},
      );

      if (res.statusCode == 200) {
        await fetchCurrentUser();
        return null;
      }

      // Backend error message
      if (res.data != null && res.data['error'] != null) {
        return res.data['error'];
      }
      return "Login gagal, periksa email & password";
    } catch (e) {
      return "Terjadi kesalahan: $e";
    } finally {
      _setLoading(false);
    }
  }

  // FETCH CURRENT USER
  Future<void> fetchCurrentUser() async {
    try {
      final res = await _api.get(ApiConfig.currentUser);
      if (res.statusCode == 200 && res.data != null) {
        _user = User.fromJson(res.data);
        notifyListeners();
      }
    } catch (_) {
      _user = null;
      notifyListeners();
    }
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout);
    } catch (_) {}

    await _api.clearCookies();

    _user = null;
    notifyListeners();
  }
}
