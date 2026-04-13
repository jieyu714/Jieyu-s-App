import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/constants/Index.dart';

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
    return _baseApi.request<Map<String, dynamic>>(
      HttpConstants.LOGIN_ENDPOINT,
      {
        "username": username,
        "passwordHash": passwordHash
      },
      (data) => data as Map<String, dynamic>
      );
  }
}