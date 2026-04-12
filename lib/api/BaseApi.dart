import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:jieyu_app/constants/Index.dart';

class ApiException implements Exception {
  final int code;
  final String message;
  
  ApiException(this.code, this.message);
}

class BaseApi {
  final String baseUrl = GlobalConstants.API_BASE_URL;
  final http.Client _httpClient;

  BaseApi({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

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

      debugPrint("成功");
      return _handleResponse(response);
    } on SocketException {
      debugPrint("無法連線至伺服器，請檢查網路設定。");
      throw ApiException(0, "無法連線至伺服器，請檢查網路設定。");
    } on http.ClientException {
      debugPrint("網路請求發生異常。");
      throw ApiException(0, "網路請求發生異常。");
    } on TimeoutException {
      debugPrint("伺服器忙碌中，請稍後再試。");
      throw ApiException(0, "伺服器忙碌中，請稍後再試。");
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }

      debugPrint("出現錯誤：" + (e as ApiException).message);
      throw ApiException(0, e.toString());
    }
  }

  dynamic _handleResponse(http.Response response) {
    final int statusCode = response.statusCode;
    final String responseBody = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      return jsonDecode(responseBody);
    } else {
      String cleanMessage = "";
      
      if (responseBody.trim().startsWith("<!DOCTYPE html>") || responseBody.contains("<html")) {
        if (statusCode == 524) {
          cleanMessage = "伺服器無回應，請稍後再試。";
          debugPrint("伺服器回應超時 (Error 524)，請稍後再試。");
        } else if (statusCode == 502 || statusCode == 503) {
          cleanMessage = "伺服器維護中。";
          debugPrint("伺服器維護中或閘道錯誤。");
        } else {
          cleanMessage = "發生錯誤，請稍後再試。";
          debugPrint("發生未知的伺服器錯誤 ($statusCode)。");
        }
      } else {
        try {
          final dynamic decoded = jsonDecode(responseBody);
          
          if (decoded is Map && decoded.containsKey('detail')) {
            final dynamic detail = decoded['detail'];
            
            if (detail is List) {
              cleanMessage = detail.map((e) {
                if (e is Map && e.containsKey('msg')) {
                  return "${e['loc'].last}: ${e['msg']}";
                }
                return e.toString();
              }).join("\n");
            } else {
              cleanMessage = detail.toString();
            }
          } else {
            cleanMessage = responseBody;
          }
        } catch (e) {
          cleanMessage = responseBody.isEmpty ? "發生錯誤，狀態碼：$statusCode" : responseBody;
        }
      }

      throw ApiException(statusCode, cleanMessage);
    }
  } 
}