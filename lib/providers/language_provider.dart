import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  String _targetLanguage = 'id'; // Default to Indonesian

  String get targetLanguage => _targetLanguage;

  bool get isIndonesian => _targetLanguage == 'id';

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _targetLanguage = prefs.getString(_languageKey) ?? 'id';
    notifyListeners();
  }

  // Localization Dictionary
  final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // General
      'app_name': 'AmbaLearn',
      'settings': 'Settings',
      'language': 'Language',
      'logout': 'Sign Out',
      'cancel': 'Cancel',
      'save': 'Save',
      'loading': 'Loading...',
      'coming_soon': 'Coming Soon',

      // Auth
      'welcome_back': 'Welcome Back',
      'sign_in_continue': 'Sign in to continue learning',
      'email': 'Email',
      'password': 'Password',
      'enter_email': 'Enter your email',
      'enter_password': 'Enter your password',
      'sign_in': 'Sign In',
      'or': 'OR',
      'continue_google': 'Continue with Google',
      'no_account': "Don't have an account?",
      'sign_up': 'Sign Up',
      'create_account': 'Create Account',
      'sign_up_started': 'Sign up to get started',
      'username': 'Username',
      'enter_username': 'Enter your username',
      'already_account': 'Already have an account?',
      'login': 'Login',

      // Drawer
      'courses': 'Courses',
      'chat': 'Chat',
      'appearance': 'Appearance',
      'account': 'Account',
      'notifications': 'Notifications',
      'help_support': 'Help & Support',
      'about': 'About',

      // Chat
      'new_chat': 'New Chat',
      'type_message': 'Type a message...',
      'thinking': 'Thinking...',
      'history': 'History',
      'no_history': 'No chat history yet',
    },
    'id': {
      // General
      'app_name': 'AmbaLearn',
      'settings': 'Pengaturan',
      'language': 'Bahasa',
      'logout': 'Keluar',
      'cancel': 'Batal',
      'save': 'Simpan',
      'loading': 'Memuat...',
      'coming_soon': 'Segera Hadir',

      // Auth
      'welcome_back': 'Selamat Datang Kembali',
      'sign_in_continue': 'Masuk untuk lanjut belajar',
      'email': 'Email',
      'password': 'Kata Sandi',
      'enter_email': 'Masukkan email anda',
      'enter_password': 'Masukkan kata sandi anda',
      'sign_in': 'Masuk',
      'or': 'ATAU',
      'continue_google': 'Lanjut dengan Google',
      'no_account': "Belum punya akun?",
      'sign_up': 'Daftar',
      'create_account': 'Buat Akun',
      'sign_up_started': 'Daftar untuk memulai',
      'username': 'Nama Pengguna',
      'enter_username': 'Masukkan nama pengguna',
      'already_account': 'Sudah punya akun?',
      'login': 'Masuk',

      // Drawer
      'courses': 'Kursus',
      'chat': 'Obrolan',
      'appearance': 'Tampilan',
      'account': 'Akun',
      'notifications': 'Notifikasi',
      'help_support': 'Bantuan & Dukungan',
      'about': 'Tentang',

      // Chat
      'new_chat': 'Obrolan Baru',
      'type_message': 'Ketik pesan...',
      'thinking': 'Berpikir...',
      'history': 'Riwayat',
      'no_history': 'Belum ada riwayat',
    },
  };

  String getText(String key) {
    return _localizedValues[_targetLanguage]?[key] ?? key;
  }

  Future<void> setLanguage(String languageCode) async {
    if (_targetLanguage == languageCode) return;

    _targetLanguage = languageCode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }
}
