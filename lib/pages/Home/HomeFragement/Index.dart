import 'package:flutter/material.dart';

class HomeFragement extends StatefulWidget {
  const HomeFragement({super.key});

  @override
  State<HomeFragement> createState() => _HomeFragementState();
}

class _HomeFragementState extends State<HomeFragement> with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container();
  }
}