import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/utils/SecurityStorageService.dart';

class AuthApi {
  final BaseApi _baseApi = BaseApi();

  /// 註冊新使用者
  /// 
  /// @param username 使用者名稱
  /// @param email 使用者電子郵件
  /// @param passwordHash 使用者密碼的哈希值
  Future<ApiResponse<Map<String, dynamic>>> registration({
    required String username,
    required String email,
    required String password,
    required String passwordHash,
    required String salt
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.REGISTRATION_ENDPOINT,
      {
        "username": username,
        "email": email,
        "password": password,
        "passwordHash": passwordHash,
        "salt": salt
      },
      (data) => data as Map<String, dynamic>
    );
  }

  // /// 請求補發 OTP 驗證碼
  // /// 
  // /// @param email 使用者電子郵件
  Future<ApiResponse<Map<String, dynamic>>> resendOtp({
    required String email
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.RESEND_OTP_ENDPOINT,
      {
        "email": email
      },
      (data) => data as Map<String, dynamic>
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyOtp({
    required String email,
    required String otp
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.VERIFY_OTP_ENDPOINT,
      {
        "email": email,
        "otp": otp
      },
      (data) => data as Map<String, dynamic>
    );
  }

  /// 驗證使用者登入
  /// 
  /// @param username 使用者名稱
  /// @param passwordHash 使用者密碼的哈希值
  /// @return 返回包含 User Info 與 Token 的 Map
  Future<ApiResponse<Map<String, dynamic>>> login(String username, String passwordHash) async {
    final result = await _baseApi.request<Map<String, dynamic>>(
      HttpConstants.LOGIN_ENDPOINT,
      {
        "username": username,
        "passwordHash": passwordHash
      },
      (data) => data as Map<String, dynamic>
    );
    
    if (result.isSuccess && result.data != null) {
      if (result.data!["token"] != null) {
        await SecurityStorageService().writeData("token", result.data!["token"]);
      }
      if (result.data!["username"] != null) {
        await SecurityStorageService().writeData("username", result.data!["username"]);
      }
      if (result.data!["id"] != null) {
        await SecurityStorageService().writeData("id", result.data!["id"]);
      }
    }

    return result;
  }

  Future<bool> verifyToken() async {
    return (await _baseApi.request<Map<String, dynamic>>(
      HttpConstants.VERIFY_TOKEN_ENDPOINT,
      {},
      (data) => data as Map<String, dynamic>
    )).isSuccess;
  }

  Future<void> logout(BuildContext context) async {    
    try {
      await _baseApi.request(
        HttpConstants.LOGOUT_ENDPOINT, 
        {}, 
        (data) => data
      );
    } finally {
      await SecurityStorageService().clearAll();
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    }
  }
}