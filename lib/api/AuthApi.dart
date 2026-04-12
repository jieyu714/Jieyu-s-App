import 'dart:convert';

import 'package:http/http.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';

class AuthApi {
  final BaseApi _baseApi = BaseApi();

  /// 註冊新使用者
  /// 
  /// @param username 使用者名稱
  /// @param email 使用者電子郵件
  /// @param passwordHash 使用者密碼的哈希值
  Future<Map<String, dynamic>> registration({
    required String username,
    required String email,
    required String password,
    required String passwordHash,
    required String salt
  }) async {
    final Map<String, dynamic> requestBody = {
      "username": username,
      "email": email,
      "password": password,
      "passwordHash": passwordHash,
      "salt": salt
    };

    try {
      final Map<String, dynamic> responseData = await _baseApi.post(HttpConstants.REGISTRATION_ENDPOINT, requestBody);
      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  /// 請求補發 OTP 驗證碼
  /// 
  /// @param email 使用者電子郵件
  Future<Map<String, dynamic>> resendOtp({
    required String email
  }) async {
    final Map<String, dynamic> requestBody = {
      "email": email,
    };

    try {
      final Map<String, dynamic> responseData = await _baseApi.post(HttpConstants.RESEND_OTP_ENDPOINT, requestBody);
      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp
  }) async {
    final Map<String, dynamic> requestBody = {
      "email": email,
      "otp": otp,
    };

    try {
      final Map<String, dynamic> responseData = await _baseApi.post(HttpConstants.VERIFY_OTP_ENDPOINT, requestBody);
      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  /// 驗證使用者登入
  /// 
  /// @param username 使用者名稱
  /// @param passwordHash 使用者密碼的哈希值
  /// @return 返回包含 User Info 與 Token 的 Map
  Future<Map<String, dynamic>> login(String username, String passwordHash) async {
    final Map<String, dynamic> requestBody = {
      "username": username,
      "passwordHash": passwordHash,
    };

    try {
      final Map<String, dynamic> responseData = await _baseApi.post(HttpConstants.LOGIN_ENDPOINT, requestBody);
      return responseData;
    } catch (e) {
      rethrow;
    }
  }
}