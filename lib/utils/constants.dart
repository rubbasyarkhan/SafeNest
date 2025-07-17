import 'package:flutter/material.dart';

class AppColors {
  static const primaryColor = Color(0xFF6A1B9A);
  static const secondaryColor = Color(0xFFD1C4E9);
  static const backgroundColor = Color(0xFFF5F5F5);
  static const textColor = Color(0xFF212121);
  static const errorColor = Colors.red;
}

class AppTextStyles {
  static const heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textColor,
  );

  static const label = TextStyle(
    fontSize: 16,
    color: AppColors.textColor,
  );
}
