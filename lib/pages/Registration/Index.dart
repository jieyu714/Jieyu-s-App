import 'package:flutter/material.dart';
import 'package:jieyu_app/api/AuthApi.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/utils/CustomCheckBox.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/PasswordHelper.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final CustomCheckBoxController _checkboxController = CustomCheckBoxController();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPasswordFocus = FocusNode();

  final AuthApi _api = AuthApi();

  final RegExp _usernameRegex = RegExp(r"^[a-zA-Z][a-zA-Z0-9_]{4,20}$");
  final RegExp _passwordRegex = RegExp(r"^[a-zA-Z0-9!@?_]{8,}$");
  final RegExp _emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _checkboxController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _registrationFormatCheck() async {
    if (_emailController.text.isEmpty || _usernameController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      ProgressDialog().showResult(context, message: "請填寫所有欄位", isError: true);
      return;
    } else if (!_emailRegex.hasMatch(_emailController.text)) {
      ProgressDialog().showResult(context, message: "請輸入正確的電子信箱");
      return;
    } else if (_usernameController.text.length < 5 || _usernameController.text.length > 20) {
      ProgressDialog().showResult(context, message: "使用者名稱長度必須在5-20個字符之間", isError: true);
      return;
    } else if (!_usernameController.text.startsWith(RegExp(r'[A-Z]'))) {
      ProgressDialog().showResult(context, message: "使用者名稱必須以大寫字母開頭", isError: true);
      return;
    } else if (!_usernameRegex.hasMatch(_usernameController.text)) {
      ProgressDialog().showResult(context, message: "使用者名稱出現不允許的字符", isError: true);
      return;
    } else if (_passwordController.text.length < 8) {
      ProgressDialog().showResult(context, message: "密碼長度至少8個字符", isError: true);
      return;
    } else if (_passwordController.text != _confirmPasswordController.text) {
      ProgressDialog().showResult(context, message: "密碼與確認密碼不符", isError: true);
      return;
    } else if (!_passwordRegex.hasMatch(_passwordController.text)) {
      ProgressDialog().showResult(context, message: "密碼出現不允許的字符", isError: true);
      return;
    } else if (!_checkboxController.isChecked) {
      ProgressDialog().showResult(context, message: "請同意使用者協議與隱私政策", isError: true);
      return;
    }

    try {
      ProgressDialog().showLoading(context, title: "註冊中...", message: "請稍候...", minDuration: 2);

      String salt = PasswordHelper().generateSalt();

      await _api.registration(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        passwordHash: PasswordHelper().hashPassword(_passwordController.text),
        salt: salt
      );
      if (!mounted) return;
      await ProgressDialog().hide(context);
      Navigator.of(context).pushNamed("/otp", arguments: {"email": _emailController.text});
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: "伺服器錯誤，請稍後再試", isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                          labelText: '電子信箱',
                          controller: _emailController,
                          textInputAction: TextInputAction.next,
                          onSubmitted: () => FocusScope.of(context).requestFocus(_usernameFocus)
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          labelText: '使用者名稱',
                          hintText: "必須以大寫字母開頭，長度5-20，允許大小寫字母、數字和_",
                          controller: _usernameController,
                          focus: _usernameFocus,
                          textInputAction: TextInputAction.next,
                          onSubmitted: () => FocusScope.of(context).requestFocus(_passwordFocus)
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          labelText: '密碼',
                          hintText: "長度至少8，允許大小寫字母、數字和!@?_",
                          controller: _passwordController,
                          focus: _passwordFocus,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          onSubmitted: () => FocusScope.of(context).requestFocus(_confirmPasswordFocus)
                        ),
                        SizedBox(height: 10),
                        CustomTextField(
                          labelText: '確認密碼',
                          controller: _confirmPasswordController,
                          focus: _confirmPasswordFocus,
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
                              "已經有帳號了？",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacementNamed("/login");
                              },
                              child: Text(
                                "登入",
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
                            _registrationFormatCheck();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor: Theme.of(context).colorScheme.primary
                          ),
                          child: Text(
                            "註冊",
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