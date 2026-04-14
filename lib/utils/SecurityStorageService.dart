import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityStorageService {

  static final SecurityStorageService _instance = SecurityStorageService._internal();
  factory SecurityStorageService() => _instance;
  SecurityStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  Future<void> writeData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint("寫入加密儲存失敗: $e");
    }
  }

  Future<String?> readData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint("讀取加密儲存失敗: $e");
      return null;
    }
  }

  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  Future<bool> hasData(String key) async {
    return await _storage.containsKey(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}