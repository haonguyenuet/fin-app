import 'package:fin_app/shared/consts/app_color.dart';
import 'package:flutter/widgets.dart';

class AppTypography {
  static const headlineLarge = TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1);
  static const headlineMedium = TextStyle(fontSize: 24, fontWeight: FontWeight.w600, height: 1);
  static const headlineSmall = TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1);
  static const title = TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1);
  static const subtitle = TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1);
  static const bodyLarge = TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1);
  static const bodyMedium = TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1);
  static const bodySmall = TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1);
  static const caption = TextStyle(fontSize: 10, fontWeight: FontWeight.w400, height: 1);
  static const button = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1);
  static final axisLabel = bodySmall.copyWith(color: AppColors.secondaryText);
}
