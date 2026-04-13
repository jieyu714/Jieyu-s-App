import 'dart:async';

import 'package:flutter/material.dart';
import 'package:jieyu_app/api/AuthApi.dart';
import 'package:jieyu_app/api/BaseApi.dart';
import 'package:jieyu_app/utils/CustomTextField.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final TextEditingController _otpController = TextEditingController();
  final WidgetStatesController _requestOtpController = WidgetStatesController();
  final AuthApi _api = AuthApi();

  Timer? _timer;
  int _countdownTime = 0;
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _requestOtpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _countdownTime = 1;
      _isButtonDisabled = true;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdownTime > 0) {
        setState(() {
          _countdownTime--;
        });
      } else {
        setState(() {
          _isButtonDisabled = false;
          _timer?.cancel();
        });
      }
    });
  }

  void _handleResendOtp(String email) async {
    if (_isButtonDisabled) return;

    _startCountdown();

    try {
      ProgressDialog().showLoading(context, title: "重新發送中...", minDuration: 2);

      await _api.resendOtp(
        email: email
      );

      if (!mounted) return;
      ProgressDialog().showResult(context, message: "發送成功", isSuccess: true);
    } on ApiResponse catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(context, message: e.message, isError: true);
    } catch (e) {
      if (!mounted) return;
      ProgressDialog().showResult(
        context,
        message: "請重新註冊",
        isError: true,
        onClose: () => Navigator.of(context).pop(),
      );
    }
  }

  void _otpFormatCheck(String email) async {
    if (_otpController.text.isEmpty) {
      ProgressDialog().showResult(context, message: "請輸入驗證碼", isError: true);
      return;
    }

    try {
      ProgressDialog().showLoading(context, title: "驗證中...", message: "請稍候...", minDuration: 2);

      await _api.verifyOtp(
        email: email,
        otp: _otpController.text
      );
      
      if (!mounted) return;
      ProgressDialog().showResult(
        context,
        message: "註冊成功",
        isSuccess: true,
        onClose: () => Navigator.of(context).pushNamedAndRemoveUntil("/login", (Route<dynamic> router) => false)
      );
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
    final Map<String, dynamic> data = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>);

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
                          labelText: '驗證碼',
                          controller: _otpController,
                          onSubmitted: () {
                            _otpFormatCheck(data["email"]);
                          },
                        ),
                        Row(
                          children: [
                            Text(
                              "沒收到驗證碼嗎？",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            TextButton(
                              statesController: _requestOtpController,
                              onPressed: _isButtonDisabled ? null : () {
                                _handleResendOtp(data["email"]);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8)
                              ),
                              child: Text(
                                _isButtonDisabled ? "再次發送（${_countdownTime.ceil()} s）" : "再次發送",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _isButtonDisabled ? Colors.grey[400] : Colors.lightBlueAccent,
                                  fontWeight: _isButtonDisabled ? FontWeight.normal : FontWeight.bold
                                ),
                              ),
                            )
                          ]
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _otpFormatCheck(data["email"]);
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