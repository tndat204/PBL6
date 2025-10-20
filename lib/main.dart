import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pbl6/core/injection_container.dart';
import 'package:pbl6/core/theme/theme.dart';
import 'package:pbl6/features/shared/auth/data/datasources/auth_remote_datasource.dart';
import 'package:pbl6/features/shared/user/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'routes/app_router.dart'; // Import router config

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Khởi tạo binding
  await SharedPreferences.getInstance();     // Khởi tạo SharedPreferences
   init();                              // Khởi tạo dependency injection (await nếu async)
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRemoteDataSource>(create: (_) => sl<AuthRemoteDataSource>()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router( // Thay MaterialApp bằng .router
      debugShowCheckedModeBanner: false,
      title: 'IT Smart Hire',
      theme: AppTheme.lightThemeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('vi', 'VN'), // hỗ trợ tiếng Việt
        Locale('en', 'US'), // fallback tiếng Anh
      ],
      routerConfig: router, // Sử dụng GoRouter config từ app_router.dart
    );
  }
}