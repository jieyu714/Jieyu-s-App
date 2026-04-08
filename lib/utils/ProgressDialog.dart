import 'package:flutter/material.dart';

class ProgressDialog {
  void showLoading(BuildContext context, {String title = "載入中...", String message = "請稍候..."}) {
    showDialog(
      context: context,
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
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(message),
              ],
            ),
          ),
        );
      },
    );
  }

  void showResult(BuildContext context, {String message = "", bool isSuccess = false, bool isError = false, bool isInfo = false, Function? onClose}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSuccess)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 40),
                      SizedBox(width: 10),
                      Text("成功", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ]
                  ),
                if (isError)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 40),
                      SizedBox(width: 10),
                      Text("錯誤", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ]
                  ),
                if (isInfo)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 40),
                      SizedBox(width: 10),
                      Text("資訊", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ]
                  ),
                SizedBox(height: 20),
                Text(message),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
  }

  void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}