// lib/features/shared/auth/presentation/pages/unauthorized_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../../routes/route_names.dart';

class UnauthorizedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Access Denied - You do not have permission'),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.LOGIN),
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}