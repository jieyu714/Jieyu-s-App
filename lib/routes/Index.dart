import 'package:flutter/material.dart';
import 'package:jieyu_app/pages/Home/Index.dart';
import 'package:jieyu_app/pages/Location/Index.dart';
import 'package:jieyu_app/pages/Login/Index.dart';
import 'package:jieyu_app/pages/Otp/Index.dart';
import 'package:jieyu_app/pages/Registration/Index.dart';
import 'package:jieyu_app/pages/Task/Index.dart';

Future<Widget> getRootWidget() async {
  const Color themeColor = Colors.lightBlueAccent;

  return MaterialApp(
    initialRoute: "/login",
    routes: getRootRoutes(),
    onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) => HomePage()),
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
    "/login": (context) => LoginPage(),
    "/registration": (context) => RegistrationPage(),
    "/otp": (context) => OtpPage(),

    "/home": (context) => HomePage(),
    "/task": (context) => TaskPage(),
    "/location": (context) => Location(),
  };
}