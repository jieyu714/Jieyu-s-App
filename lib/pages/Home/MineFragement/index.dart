import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:jieyu_app/api/AuthApi.dart';
import 'package:jieyu_app/utils/SecurityStorageService.dart';

class MineFragement extends StatefulWidget {
  const MineFragement({super.key});

  @override
  State<MineFragement> createState() => _MineFragementState();
}

class _MineFragementState extends State<MineFragement> {
  String username = "用戶";
  String userId = "";

  Widget _buildMenuItem(IconData icon, String title, {Color? textColor, Function? function}) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10),
      onTap: () => {
        if (function != null) function()
      },
    );
  }

  void _loadUserInfo() async {
    final String? saveUsername = await SecurityStorageService().readData("username");
    final String? saveId = await SecurityStorageService().readData("id");

    if (mounted) {
      setState(() {
        if (saveUsername != null) {
          username = saveUsername;
        }
        if (saveId != null) {
          userId = saveId;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlueAccent,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 60, 20, 20),
            padding: EdgeInsets.all(20),
            height: 160,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: Offset(0, 5)
                )
              ]
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage("assets/visitor.jpg"),
                      fit: BoxFit.cover
                    ),
                    border: Border.all(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
                      width: 3
                    )
                  )
                ),
                SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    SizedBox(height: 5),
                    Text(
                      "ID: $userId",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey
                      )
                    ),
                  ]
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey
                )
              ]
            )
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))
              ),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(Icons.message, "通知"),
                  Divider(height: 40, thickness: 1),
                  _buildMenuItem(Icons.settings_outlined, "設置"),
                  _buildMenuItem(Icons.help_outline, "幫助與回饋"),
                  _buildMenuItem(Icons.logout, "登出帳號", textColor: Colors.redAccent, function: () async {
                    await AuthApi().logout(context);
                    Navigator.of(context).pushNamedAndRemoveUntil("/login", (Route<dynamic> router) => false);
                  })
                ],
              )
              // child: Text("")
            )
          )
        ]
      )
    );
  }
}