import 'package:flutter/material.dart';
import 'package:jieyu_app/pages/Home/AppsFragement/Index.dart';
import 'package:jieyu_app/pages/Home/HomeFragement/Index.dart';
import 'package:jieyu_app/pages/Home/MineFragement/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<String> _navigationItems = ["首頁", "應用", "我的"];
  List<IconData> _navigationIcons = [Icons.home, Icons.apps, Icons.person];
  int _currentIndex = 0;

  List<Widget> _buildPages() {
    return [
      Center(child: HomeFragement()),
      Center(child: AppsFragement()),
      Center(child: MineFragement()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: _buildPages(),
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) => {
          setState(() {
            _currentIndex = value;
          })
        },
        items: List.generate(_navigationIcons.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_navigationIcons[index]),
            label: _navigationItems[index],
          );
        }),
      ),
    );
  }
}