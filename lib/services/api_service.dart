import 'dart:developer';
import 'package:flutter/foundation.dart'; // kIsWeb
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../config/api_config.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../models/user_model.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio dio;
  late CookieJar cookieJar;

  ApiService._internal() {
    cookieJar = CookieJar();

    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Cookie manager
    if (!kIsWeb) {
      dio.interceptors.add(CookieManager(cookieJar));
    }

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  // GENERIC GET
  Future<Response> get(String path, {Map<String, dynamic>? query}) async {
    try {
      return await dio.get(path, queryParameters: query);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GENERIC POST
  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // =============================
  // LOGIN GOOGLE
  // =============================
  // Future<User?> loginWithGoogle() async {
  //   try {
  //     final googleSignIn = GoogleSignIn(scopes: ['email']);
  //     final googleUser = await googleSignIn.signIn();

  //     if (googleUser == null) return null; // user batal login

  //     final googleAuth = await googleUser.authentication;

  //     final response = await dio.post(
  //       ApiConfig.googleAuth,
  //       data: {"credential": googleAuth.idToken},
  //     );

  //     if (response.statusCode == 200 && response.data != null) {
  //       return User.fromJson(response.data);
  //     }

  //     return null;
  //   } catch (e, st) {
  //     log("Google Login Error: $e\n$st");
  //     return null;
  //   }
  // }

  // CLEAR COOKIES
  Future<void> clearCookies() async {
    if (!kIsWeb) {
      await cookieJar.deleteAll();
    }
  }

  // ERROR HANDLER
  Exception _handleError(DioException e) {
    String message = "Unexpected error";

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Server took too long to respond";
        break;
      case DioExceptionType.badResponse:
        message = "Server error: ${e.response?.statusCode}";
        break;
      case DioExceptionType.connectionError:
        message = "No internet connection";
        break;
      default:
        message = e.message ?? "Unexpected error";
    }

    log("API ERROR: $message");
    return Exception(message);
  }
}
