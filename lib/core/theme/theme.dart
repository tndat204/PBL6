import 'package:flutter/material.dart';
import 'package:pbl6/core/theme/app_pallete.dart';

class AppTheme {
  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.backgroundColor,
    primaryColor: AppPallete.primaryColor,
    colorScheme: ColorScheme.light(
      primary: AppPallete.primaryColor,
      secondary: AppPallete.secondaryColor,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(color: AppPallete.textColor, fontSize: 24, fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(color: AppPallete.textColor),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: AppPallete.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppPallete.primaryColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPallete.primaryColor,
        foregroundColor: AppPallete.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}