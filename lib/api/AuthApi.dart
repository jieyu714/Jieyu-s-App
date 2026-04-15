import 'package:flutter/material.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/utils/SecurityStorageService.dart';

class AuthApi {
  final BaseApi _baseApi = BaseApi();

  Future<ApiResponse<Map<String, dynamic>>> registration({
    required String username,
    required String email,
    required String password,
    required String passwordHash,
    required String salt
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.REGISTRATION,
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

  Future<ApiResponse<Map<String, dynamic>>> resendOtp({
    required String email
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.RESEND_OTP,
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
      HttpConstants.VERIFY_OTP,
      {
        "email": email,
        "otp": otp
      },
      (data) => data as Map<String, dynamic>
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> login(String username, String passwordHash) async {
    final result = await _baseApi.request<Map<String, dynamic>>(
      HttpConstants.LOGIN,
      {
        "username": username,
        "passwordHash": passwordHash
      },
      (data) => data as Map<String, dynamic>
    );
    
    if (result.isSuccess && result.data != null) {
      if (result.data!["token"] != null) {
        await SecurityStorageService().writeData(SecurityStorageServiceConstant.TOKEN, result.data!["token"]);
      }
      if (result.data!["username"] != null) {
        await SecurityStorageService().writeData(SecurityStorageServiceConstant.USERNAME, result.data!["username"]);
      }
      if (result.data!["id"] != null) {
        await SecurityStorageService().writeData(SecurityStorageServiceConstant.ID, result.data!["id"]);
      }
    }

    return result;
  }

  Future<bool> verifyToken() async {
    return (await _baseApi.request<Map<String, dynamic>>(
      HttpConstants.VERIFY_TOKEN,
      {},
      (data) => data as Map<String, dynamic>
    )).isSuccess;
  }

  Future<ApiResponse<Map<String, dynamic>>> getUserInfo() async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.GET_USER_INFO,
      {},
      (data) => data as Map<String, dynamic>
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserInfo({
    required String name,
    required String? gender,
    required DateTime? birthday,
    required String? phone,
    required String? address
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.UPDATE_USER_INFO,
      {
        "name": name,
        "gender": gender,
        "birthday": birthday?.toIso8601String(),
        "phone": phone,
        "address": address
      },
      (data) => data as Map<String, dynamic>
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword({
    required String oldPasswordHash,
    required String newPassword,
    required String newPasswordHash
  }) async {
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.CHANGE_PASSWORD,
      {
        "oldPasswordHash": oldPasswordHash,
        "newPassword": newPassword,
        "newPasswordHash": newPasswordHash
      },
      (data) => data as Map<String, dynamic>
    );
  }

  Future<void> logout(BuildContext context) async {    
    try {
      await _baseApi.request(
        HttpConstants.LOGOUT, 
        {}, 
        (data) => data
      );
    } finally {
      await SecurityStorageService().clearAll();
      Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
    }
  }
}