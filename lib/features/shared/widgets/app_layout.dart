import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../user/domain/entities/user.dart';
import 'custom_app_bar.dart';
import 'custom_bottom_nav.dart';

class AppLayout extends StatefulWidget {
  final User user;
  final Widget child;
  final List<String> routes;
  final List<BottomNavigationBarItem> items;

  const AppLayout({
    super.key,
    required this.user,
    required this.child,
    required this.routes,
    required this.items,
  });

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: widget.child,
      bottomNavigationBar: CustomBottomNav(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() => currentIndex = index);
          context.go(widget.routes[index]);
        },
        items: widget.items,
      ),
    );
  }
}
