import 'package:flutter/material.dart';
import 'package:jieyu_app/utils/ProgressDialog.dart';

class AppsFragement extends StatefulWidget {
  const AppsFragement({super.key});

  @override
  State<AppsFragement> createState() => _AppsFragementState();
}

class _AppsFragementState extends State<AppsFragement> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  final List<List> _apps = [
    ["地點", Icons.location_on, "/location"],
    ["待辦清單", Icons.check_box, "/task"],
    ["債務管理", Icons.splitscreen, "/debt"],
    ["出勤與薪資", Icons.attach_money],
    ["英文單字", Icons.sort_by_alpha],
    ["鬧鐘", Icons.alarm],
    ["課程與學分", Icons.school],
    ["天氣", Icons.cloud],
    ["發票", Icons.receipt_long],
    ["穿衣搭配", Icons.checkroom],
    ["行程規劃", Icons.event],
    ["SOP紀錄", Icons.description],
    ["心情紀錄", Icons.mood],
    ["記帳", Icons.account_balance],
    ["飲食紀錄", Icons.restaurant],
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListView.builder(
      itemCount: _apps.length,
      itemBuilder: (context, index) {
        final app = _apps[index];
        return TextButton(
          onPressed: () {
            if (app.length > 2 && app[2]!= null) {
              Navigator.pushNamed(context, app[2]);
            } else {
              ProgressDialog().showResult(context, message: "${app[0]} 功能尚未開發", isInfo: true);
            }
          },
          child: ListTile(
            leading: Icon(app[1] as IconData),
            title: Text(app[0]!, style: TextStyle(color: app.length > 2 &&app[2] != null ? Theme.of(context).colorScheme.primary : Colors.grey)),
          ),
        );
      },
    );
  }
}