import 'package:flutter/material.dart';
import 'package:jieyu_app/pages/Home/Index.dart';
import 'package:jieyu_app/pages/Location/Index.dart';
import 'package:jieyu_app/pages/Login/Index.dart';

Widget getRootWidget() {
  const Color themeColor = Colors.lightBlueAccent;

  return MaterialApp(
    initialRoute: "/home",
    routes: getRootRoutes(),
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeColor,
        primary: themeColor,
      ),
    ),
  );
}

Map<String, Widget Function(BuildContext)> getRootRoutes() {
  return {
    "/": (context) => LoginPage(),
    "/home": (context) => HomePage(),
    "/location": (context) => Location(),
  };
}