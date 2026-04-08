import 'package:flutter/material.dart';
import 'package:jieyu_app/utils/CustomCheckBox.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _accountController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  CustomCheckBoxController _checkboxController = CustomCheckBoxController();

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
                          labelText: '帳號',
                          controller: _accountController,
                        ),
                        SizedBox(height: 20),
                        CustomTextField(
                          labelText: '密碼',
                          controller: _passwordController,
                          obscureText: true,
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
                            // Handle login logic here
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