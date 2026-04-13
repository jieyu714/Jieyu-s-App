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

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> _buildPages() {
    return [
      HomeFragement(),
      AppsFragement(),
      MineFragement(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (value) => {
            setState(() {
              _currentIndex = value;
            })
          },
          children: _buildPages(),
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (value) => {
          _pageController.animateToPage(
            value,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          )
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