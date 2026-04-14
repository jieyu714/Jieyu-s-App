import 'package:flutter/material.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';
import 'package:jieyu_app/viewmodels/HomeFragement.dart';

class AppsFragement extends StatefulWidget {
  const AppsFragement({super.key});

  @override
  State<AppsFragement> createState() => _AppsFragementState();
}

class _AppsFragementState extends State<AppsFragement> {

  final List<App> _apps = [
    App(name: "出勤與薪資", icon: Icons.attach_money),
    App(name: "英文單字", icon: Icons.sort_by_alpha),
    App(name: "鬧鐘", icon: Icons.alarm),
    App(name: "課程與學分", icon: Icons.school),
    App(name: "地點", icon: Icons.location_on, page: "/location"),
    App(name: "天氣", icon: Icons.cloud),
    App(name: "發票", icon: Icons.receipt_long),
    App(name: "穿衣搭配", icon: Icons.checkroom),
    App(name: "行程規劃", icon: Icons.event),
    App(name: "SOP紀錄", icon: Icons.description),
    App(name: "待辦清單", icon: Icons.check_box, page: "/task"),
    App(name: "心情紀錄", icon: Icons.mood),
    App(name: "記帳", icon: Icons.account_balance),
    App(name: "飲食紀錄", icon: Icons.restaurant),
    App(name: "欠還款紀錄", icon: Icons.splitscreen),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        itemCount: _apps.length,
        itemBuilder: (context, index) {
          final app = _apps[index];
          return TextButton(
            onPressed: () {
              if (app.page != null) {
                Navigator.pushNamed(context, app.page!);
              } else {
                ProgressDialog().showResult(context, message: "${app.name} 功能尚未開發", isInfo: true);
              }
            },
            child: ListTile(
              leading: Icon(app.icon as IconData),
              title: Text(app.name!, style: TextStyle(color: app.page != null ? Theme.of(context).colorScheme.primary : Colors.grey)),
            ),
          );
        },
      ),
    );
  }
}