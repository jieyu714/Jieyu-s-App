import 'package:flutter/material.dart';
import 'package:jieyu_app/pages/Debt/ContactsFragement/Index.dart';
import 'package:jieyu_app/pages/Debt/RecordsFragement/Index.dart';

class DebtPage extends StatefulWidget {
  const DebtPage({super.key});

  @override
  State<DebtPage> createState() => _DebtPageState();
}

class _DebtPageState extends State<DebtPage> {
  final List<String> _navigationItems = ["人員名單", "帳務明細"];
  final List<IconData> _navifationIcons = [Icons.person, Icons.receipt_long];

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
      ContactsFragement(),
      RecordsFragement()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("債務管理"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: _buildPages(),
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut
          );
        },
        items: List.generate(_navigationItems.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_navifationIcons[index]),
            label: _navigationItems[index]
          );
        })
      ),
    );
  }
}