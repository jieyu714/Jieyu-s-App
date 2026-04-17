import 'package:flutter/material.dart';
import 'package:jieyu_app/pages/Invoice/InvoiceEntryFragement/Index.dart';
import 'package:jieyu_app/pages/Invoice/InvoiceList/Index.dart';
import 'package:jieyu_app/pages/Invoice/WinningInvoiceFragement/Index.dart';

class InvoicePage extends StatefulWidget {
  const InvoicePage({super.key});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {

  final List<String> _navigationItems = ["中獎發票", "發票輸入", "發票一覽"];
  final List<IconData> _navigationIcons = [Icons.card_giftcard, Icons.edit, Icons.list];

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
      WinningInvoiceFragement(),
      InvoiceEntryFragement(),
      InvoiceListFragement()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("發票"),
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
        )
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: List.generate(_navigationItems.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_navigationIcons[index]),
            label: _navigationItems[index],
          );
        }),
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut
          );
        },
      ),
    );
  }
}