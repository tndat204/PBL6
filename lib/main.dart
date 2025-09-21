import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/theme.dart';
import 'package:pbl6/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/auth/presentation/pages/welcome_page.dart';
import 'package:pbl6/injection_container.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Khởi tạo binding
  await SharedPreferences.getInstance();     // Khởi tạo SharedPreferences
  init();                                   // Khởi tạo dependency injection
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRemoteDataSource>(create: (_) => sl<AuthRemoteDataSource>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IT Smart Hire',
      theme: AppTheme.lightThemeMode,
      home: const WelcomePage(),
    );
  }
}