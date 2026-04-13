import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jieyu_app/constants/Index.dart';

class ApiResponse<T> implements Exception {
  final int? statusCode;
  final String status;
  final String message;
  final T? data;

  ApiResponse({
    this.statusCode,
    this.status = "error",
    this.message = "",
    this.data,
  });

  bool get isSuccess => status == "success";

  @override
  String toString() => message;

  String getdata() => data.toString();

  factory ApiResponse.fromResponse(int httpCode, dynamic body, T Function(dynamic)? fromJsonT) {
    String apiStatus = "error";
    String apiMessage = "發生錯誤 ($httpCode)";
    T? apiData;

    try {
      final decoded = (body is String && body.isNotEmpty) ? jsonDecode(body) : body;
      
      if (decoded is Map) {
        final map = decoded.containsKey('detail') ? decoded['detail'] : decoded;
        
        if (map is Map) {
          apiStatus = map['status']?.toString() ?? (httpCode >= 200 && httpCode < 300 ? "success" : "error");
          apiMessage = map['message']?.toString() ?? apiMessage;
          apiData = (map['data'] != null && fromJsonT != null) ? fromJsonT(map['data']) : map['data'];
        }
      }
    } catch (_) {}

    return ApiResponse<T>(
      statusCode: httpCode,
      status: apiStatus,
      message: apiMessage,
      data: apiData,
    );
  }
}

class BaseApi {
  final String baseUrl = GlobalConstants.API_BASE_URL;
  final http.Client _httpClient;

  BaseApi({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    
    try {
      final http.Response response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(Duration(seconds: GlobalConstants.TIMEOUT_DURATION_SECONDS));
      
      return _handleResponse(response);
    } on SocketException {
      throw ApiResponse(message: "無法連線至伺服器，請檢查網路設定", statusCode: 0);
    } on TimeoutException {
      throw ApiResponse(message: "伺服器忙碌中，請稍後再試", statusCode: 408);
    } on http.ClientException {
      throw ApiResponse(message: "網路異常，請稍後再試", statusCode: 0);
    } catch (e) {
      if (e is ApiResponse) rethrow;
      throw ApiResponse(message: "系統邊界錯誤：$e", statusCode: 500);
    }
  }

  Future<ApiResponse<T>> request<T>(
  String endpoint, 
  Map<String, dynamic> data, 
  T Function(dynamic)? fromJsonT
) async {
  try {
    final responseBody = await post(endpoint, data);

    final response = ApiResponse<T>.fromResponse(
      200, 
      responseBody, 
      fromJsonT
    );
    
    if (!response.isSuccess) {
      throw response;
    }
    
    return response;
  } on ApiResponse {
    rethrow;
  } catch (e) {
    throw ApiResponse(
      status: "error",
      message: "系統處理異常: $e",
      statusCode: 500,
    );
  }
}

  dynamic _handleResponse(http.Response response) {
  final result = ApiResponse<dynamic>.fromResponse(
    response.statusCode, 
    response.body, 
    null
  );

  if (result.isSuccess) {
    return response.body; 
  } else {
    throw result; 
  }
}
}