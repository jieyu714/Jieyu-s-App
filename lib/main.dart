import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jieyu_app/routes/Index.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    WakelockPlus.enable().catchError((Object error) {
      debugPrint("無法啟用 Wakelock: $error");
    });
  }  
  
  runApp(getRootWidget());
}