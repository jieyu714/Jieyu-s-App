import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  PreferenceService._internal();
  static final PreferenceService _instance = PreferenceService._internal();
  factory PreferenceService() => _instance;

  Future<bool> saveData<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is String) return await prefs.setString(key, value);
    if (value is int) return await prefs.setInt(key, value);
    if (value is double) return await prefs.setDouble(key, value);
    if (value is bool) return await prefs.setBool(key, value);
    if (value is List<String>) return await prefs.setStringList(key, value);
    
    throw Exception("不支援的資料型態: ${value.runtimeType}");
  }

  Future<T?> getData<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final dynamic data = prefs.get(key);
    
    if (data == null) return null;
    return data as T;
  }

  Future<bool> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(key);
  }

  Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }
}