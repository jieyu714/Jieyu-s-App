import 'package:flutter/material.dart';
import 'package:jieyu_app/constants/Index.dart';
import 'package:jieyu_app/pages/Home/Index.dart';
import 'package:jieyu_app/pages/Location/Index.dart';
import 'package:jieyu_app/pages/Login/Index.dart';
import 'package:jieyu_app/pages/Otp/Index.dart';
import 'package:jieyu_app/pages/Profile/Index.dart';
import 'package:jieyu_app/pages/Registration/Index.dart';
import 'package:jieyu_app/pages/Settings/Index.dart';
import 'package:jieyu_app/pages/Task/Index.dart';
import 'package:jieyu_app/utils/SharedPreference.dart';

final ValueNotifier<Color> appThemeNotifier = ValueNotifier(Colors.lightBlueAccent);

Future<Widget> getRootWidget() async {
  WidgetsFlutterBinding.ensureInitialized();

  final String? savedColorHex = await PreferenceService().getData(SharedPreferenceConstant.APP_THEME_COLOR);
  
  if (savedColorHex != null) {
    final int colorValue = int.parse(savedColorHex);
    appThemeNotifier.value = Color(colorValue);
  } else {
    appThemeNotifier.value = Colors.lightBlueAccent;
  }
  
  return ValueListenableBuilder<Color>(
    valueListenable: appThemeNotifier,
    builder: (context, currentThemeColor, child) {
      return MaterialApp(
        initialRoute: "/login",
        routes: getRootRoutes(),
        onUnknownRoute: (settings) => MaterialPageRoute(builder: (context) => const HomePage()),
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: currentThemeColor,
            primary: currentThemeColor,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: currentThemeColor,
            foregroundColor: Colors.white,
          ),
        ),
      );
    },
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
    "/settings": (context) => SettingsPage(),
    "/profile": (context) => ProfilePage(),
  };
}