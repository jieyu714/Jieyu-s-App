import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/utils/SecurityStorageService.dart';

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
    String apiStatus = (httpCode >= 200 && httpCode < 300) ? "success" : "error";
    String apiMessage = "發生錯誤 ($httpCode)";
    T? apiData;
    debugPrint(body.toString());
    try {
      final dynamic decoded = (body is String && body.isNotEmpty) ? jsonDecode(body) : body;

      if (decoded is Map) {
        final Map<String, dynamic> map = decoded.containsKey('detail') 
            ? (decoded['detail'] is Map ? decoded['detail'] : {'message': decoded['detail'].toString()})
            : Map<String, dynamic>.from(decoded);
        
        apiStatus = map['status']?.toString() ?? apiStatus;
        apiMessage = map['message']?.toString() ?? map['detail']?.toString() ?? apiMessage;
        
        if (map['data'] != null && fromJsonT != null) {
          apiData = fromJsonT(map['data']);
        } else {
          apiData = map['data'] as T?;
        }
      }
    } catch (e) {
      debugPrint("【解析異常】: $e \n原始內容: $body");
      apiMessage = "資料解析失敗";
    }
    
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
  
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  String? _token;
  String? _deviceId;

  BaseApi({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Future<String> _getDeviceId() async {
    if (_deviceId != null) return _deviceId!;

    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        _deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        _deviceId = iosInfo.identifierForVendor;
      }
    } catch (e) {
      debugPrint("無法獲取設備資訊: $e");
      _deviceId = "unknown_device"; 
    }
    
    return _deviceId ?? "unknown_device";
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final Uri url = Uri.parse('$baseUrl$endpoint');
    
    _token = _token ?? await SecurityStorageService().readData(SecurityStorageServiceConstant.TOKEN);
    await _getDeviceId();

    final Map<String, dynamic> finalData = {
      ...data,
      "deviceId": _deviceId
    };
    
    try {
      final http.Response response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token'
        },
        body: jsonEncode(finalData),
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

      return ApiResponse<T>.fromResponse(200, responseBody, fromJsonT);
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