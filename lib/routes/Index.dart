import 'package:flutter/material.dart';
import 'package:jieyu_app/pages/Login/Index.dart';

Widget getRootWidget() {
  const Color themeColor = Colors.lightBlueAccent;

  return MaterialApp(
    initialRoute: "/",
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
    "/": (context) => LoginPage()
  };
}