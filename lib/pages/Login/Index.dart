import 'package:flutter/material.dart';
import 'package:jieyu_app/utils/CustomCheckBox.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
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

  // final RegExp _usernameRegex = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{4,20}$');
  // final RegExp _passwordRegex = RegExp(r'^[a-zA-Z0-9!@?_]{8,}$');

  void _loginFormatCheck() {
    if (_usernameController.text.isEmpty || _passwordController.text.isEmpty) {
      ProgressDialog().showResult(context, message: "請填寫所有欄位", isError: true);
      return;
    } else if (_usernameController.text.length < 5 || _usernameController.text.length > 20) {
      ProgressDialog().showResult(context, message: "使用者名稱長度必須在5-20個字符之間", isError: true);
      return;
    } else if (!_usernameController.text.startsWith(RegExp(r'[A-Z]'))) {
      ProgressDialog().showResult(context, message: "使用者名稱必須以大寫字母開頭", isError: true);
      return;
    } else if (!RegExp(r'^[A-Z][a-zA-Z0-9_]{4,19}$').hasMatch(_usernameController.text)) {
      ProgressDialog().showResult(context, message: "使用者名稱出現不允許的字符", isError: true);
      return;
    } else if (_passwordController.text.length < 8) {
      ProgressDialog().showResult(context, message: "密碼長度至少8個字符", isError: true);
      return;
    } else if (!RegExp(r'^[a-zA-Z0-9!@?_]{8,}$').hasMatch(_passwordController.text)) {
      ProgressDialog().showResult(context, message: "密碼出現不允許的字符", isError: true);
      return;
    } else if (!_checkboxController.isChecked) {
      ProgressDialog().showResult(context, message: "請同意使用者協議與隱私政策", isError: true);
      return;
    } else {
      ProgressDialog().showLoading(context, title: "登入中...", message: "請稍候...");
      Future.delayed(Duration(seconds: 2), () {
        ProgressDialog().hide(context);
        ProgressDialog().showResult(context, message: "登入成功", isSuccess: true, onClose: () {
          // TODO: 處理登入成功後的邏輯
          print("登入成功，執行後續操作");
          Navigator.pushNamed(context, "/home");
        });
      });
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
                          hintText: "必須以大寫字母開頭，長度5-20，允許大小寫字母、數字和_",
                          controller: _usernameController
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          labelText: '密碼',
                          hintText: "長度至少8，允許大小寫字母、數字和!@?_",
                          controller: _passwordController,
                          obscureText: true
                        ),
                        SizedBox(height: 20),
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
                                // Handle registration logic here
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
          ],
        ),
      ),
    );
  }
}