import 'dart:async';
import 'package:flutter/material.dart';

class _AnimatedEllipsisText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const _AnimatedEllipsisText({required this.text, this.style});

  @override
  State<_AnimatedEllipsisText> createState() => _AnimatedEllipsisTextState();
}

class _AnimatedEllipsisTextState extends State<_AnimatedEllipsisText> {
  int _dotCount = 0;
  Timer? _timer;
  late String _baseText;
  late bool _shoudAnimate;

  @override
  void initState() {
    super.initState();
    _shoudAnimate = widget.text.endsWith("...");
    _baseText = _shoudAnimate ? widget.text.substring(0, widget.text.length - 3) : widget.text;

    if (_shoudAnimate) {
      _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
        if (mounted) {
          setState(() {
            _dotCount = (_dotCount + 1) % 4;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shoudAnimate) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            _baseText,
            style: widget.style
          ),
          SizedBox(width: 1),
          Stack(
            alignment: AlignmentGeometry.bottomLeft,
            children: [
              Opacity(
                opacity: 0,
                child: Text(
                  "...",
                  style: widget.style
                )
              ),
              Text(
                '.' * _dotCount,
                style: widget.style,
              )
            ],
          )
        ],
      );
    } else {
      return Text(
        widget.text,
        style: widget.style
      );
    }
  }
}

class ProgressDialog {
  ProgressDialog._internal();

  static final ProgressDialog _instance = ProgressDialog._internal();

  factory ProgressDialog() => _instance;

  bool _isShowing = false;

  DateTime? _startTime;
  int _minDuration = 0;

  bool isShowing() => _isShowing;

  Future<bool> showLoading(
    BuildContext context,
    {
      String title = "載入中...",
      String message = "請稍候...",
      int minDuration = 0
    }) async {
    if (_isShowing) await hide(context);

    _setInfo(true, minDuration > 0 ? DateTime.now() : null, minDuration);

    if (!context.mounted) return false;

    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                _AnimatedEllipsisText(text: title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                _AnimatedEllipsisText(text: message)
              ],
            ),
          ),
        );
      },
    );

    return true;
  }

  Future<bool> showResult(
    BuildContext context,
    {
      String message = "",
      bool isSuccess = false,
      bool isError = false,
      bool isInfo = false,
      Function? onClose
    }) async {
    if (_isShowing) await hide(context);

    _setInfo(true, null, 0);

    if (!context.mounted) return false;

    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSuccess) _buildResultHeader(Icons.check_circle, Colors.green, "成功"),
                if (isError) _buildResultHeader(Icons.error, Colors.red, "錯誤"),
                if (isInfo) _buildResultHeader(Icons.info, Colors.blue, "資訊"),
                SizedBox(height: 20),
                Text(message),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () async {
                    await hide(dialogContext);
                    if (onClose != null) onClose();
                  },
                  child: Text("確認"),
                )
              ]
            ),
          ),
        );
      },
    );

    return true;
  }

  Future<bool> showConfirm(
    BuildContext context, {
    required String title,
    required String body,
    String confirmText = "確認",
    String cancelText = "取消"
  }) async {
    if (_isShowing) await hide(context);

    _setInfo(true, null, 0);

    if (!context.mounted) return false;

    final bool? result = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  body,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _isShowing = false;
                        Navigator.of(dialogContext).pop(false);
                      },
                      child: Text(cancelText, style: TextStyle(color: Colors.grey)),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        _isShowing = false;
                        Navigator.of(dialogContext).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(confirmText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    _isShowing = false;
    return result ?? false;
  }

  Widget _buildResultHeader(IconData icon, Color color, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 40),
        SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ]
    );
  }

  Future<void> _checkMinDuration() async {
    if (_startTime == null || _minDuration <= 0) {
      return;
    }

    if (DateTime.now().difference(_startTime!) < Duration(seconds: _minDuration)) {
      await Future.delayed(Duration(seconds: _minDuration) - DateTime.now().difference(_startTime!));
      _setInfo(_isShowing, null, 0);
    }
  }

  void _setInfo(bool isShowing, DateTime? startTime, int minDuration) {
    _isShowing = isShowing;
    _startTime = startTime;
    _minDuration = minDuration;
  }

  Future<bool> hide(BuildContext context) async {
    if (!_isShowing) return false;

    await _checkMinDuration();

    _setInfo(false, null, 0);

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }

    return true;
  }
}