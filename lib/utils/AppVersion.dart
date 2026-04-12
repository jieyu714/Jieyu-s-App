import 'package:package_info_plus/package_info_plus.dart';

// 取得版本資訊的函式
Future<String> getAppVersion() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  
  String version = packageInfo.version;
  
  return "v$version";
}