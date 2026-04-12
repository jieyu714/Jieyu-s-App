import 'package:flutter/material.dart';
import 'package:jieyu_app/api/AuthApi.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/utils/AppVersion.dart';
import 'package:jieyu_app/utils/CustomCheckBox.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/PasswordHelper.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final CustomCheckBoxController _checkboxController = CustomCheckBoxController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  final RegExp _usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{4,20}$');
  final RegExp _passwordRegex = RegExp(r'^[a-zA-Z0-9!@?_]{8,}$');

  final AuthApi _api = AuthApi();
  String _appVersion = "";
  
  @override
  void initState() {
    super.initState();
    getAppVersion().then((value) {
      setState(() {
        _appVersion = value;
      });
    });
  }

  void _loginFormatCheck() async {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ProgressDialog().showResult(context, message: "請填寫所有欄位", isError: true);
      return;
    } else if (!_checkboxController.isChecked) {
      ProgressDialog().showResult(context, message: "請同意使用者協議與隱私政策", isError: true);
      return;
    }

    ProgressDialog().showLoading(context, title: "登入中...", minDuration: 2);
    
    if (_usernameController.text.length < 5 || _usernameController.text.length > 20) {
      ProgressDialog().showResult(context, message: "帳號或密碼錯誤", isError: true);
      return;
    } else if (!_usernameController.text.startsWith(RegExp(r'[A-Z]'))) {
      ProgressDialog().showResult(context, message: "帳號或密碼錯誤", isError: true);
      return;
    } else if (!_usernameRegex.hasMatch(_usernameController.text)) {
      ProgressDialog().showResult(context, message: "帳號或密碼錯誤", isError: true);
      return;
    } else if (_passwordController.text.length < 8) {
      ProgressDialog().showResult(context, message: "帳號或密碼錯誤", isError: true);
      return;
    } else if (!_passwordRegex.hasMatch(_passwordController.text)) {
      ProgressDialog().showResult(context, message: "帳號或密碼錯誤", isError: true);
      return;
    } else {
      try {
        await _api.login(_usernameController.text, PasswordHelper().hashPassword(_passwordController.text));
        if (!mounted) return;
        ProgressDialog().showResult(
          context,
          message: "登入成功",
          isSuccess: true,
          onClose: () => Navigator.of(context).pushNamedAndRemoveUntil("/home", (Route<dynamic> router) => false),
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        ProgressDialog().showResult(context, message: e.message, isError: true);
      } catch (e) {
        if (!mounted) return;
        ProgressDialog().showResult(context, message: "伺服器錯誤，請稍後再試", isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Jieyu\'s App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          spreadRadius: 5,
                          blurRadius: 10,
                          offset: const Offset(5, 5),
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.5),
                          spreadRadius: -2,
                          blurRadius: 5,
                          offset: const Offset(-3, -3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          labelText: '使用者名稱',
                          controller: _usernameController,
                          focus: _usernameFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: () => FocusScope.of(context).requestFocus(_passwordFocus),
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          labelText: '密碼',
                          controller: _passwordController,
                          focus: _passwordFocus,
                          obscureText: true
                        ),
                        SizedBox(height: 10),
                        CustomCheckBox(
                          controller: _checkboxController,
                          label: "已詳閱並同意《使用者協議》與《隱私政策》",
                          size: 10
                        ),
                        Row(
                          children: [
                            Text(
                              "還沒有帳號？",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed("/registration");
                              },
                              child: Text(
                                "註冊",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                            )
                          ]
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _loginFormatCheck();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.primary
                          ),
                          child: Text(
                            "登入",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 10,
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  _appVersion,
                  style: TextStyle(
                    color: Colors.grey[400]
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}