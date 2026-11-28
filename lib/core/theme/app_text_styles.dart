import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTextStyles {
  static TextStyle _inter(
    double size,
    FontWeight weight, {
    Color? color,
    TextDecoration? decoration,
    Color? decorationColor,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: weight,
    color: color,
    decoration: decoration,
    decorationColor: decorationColor,
  );

  static final TextStyle pageTitle = _inter(
    26,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle brand = _inter(
    17,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle sectionTitle = _inter(
    16,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle cardTitle = _inter(
    16,
    FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static final TextStyle body = _inter(
    14,
    FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static final TextStyle bodyStrong = _inter(
    14,
    FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static final TextStyle bodySecondary = _inter(
    14,
    FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static final TextStyle subtitle = _inter(
    13,
    FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static final TextStyle rowLabel = _inter(
    13,
    FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static final TextStyle rowValue = _inter(
    13,
    FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static final TextStyle caption = _inter(
    12,
    FontWeight.w400,
    color: AppColors.textSecondary,
  );
  static final TextStyle label = _inter(
    12,
    FontWeight.w600,
    color: AppColors.textSecondary,
  );
  static final TextStyle captionBold = _inter(
    12,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle kpiValue = _inter(
    24,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle balanceValue = _inter(
    28,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle summaryValue = _inter(
    20,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle button = _inter(14, FontWeight.w600);
  static final TextStyle buttonSmall = _inter(13, FontWeight.w600);
  static final TextStyle link = _inter(
    13,
    FontWeight.w600,
    color: AppColors.primaryDark,
    decoration: TextDecoration.underline,
    decorationColor: AppColors.primaryDark,
  );
  static final TextStyle badge = _inter(12, FontWeight.w600);
  static final TextStyle navItem = _inter(
    14,
    FontWeight.w400,
    color: AppColors.textPrimary,
  );
  static final TextStyle navItemActive = _inter(
    14,
    FontWeight.w600,
    color: AppColors.primaryDark,
  );
  // Part 2 additions
  static final TextStyle dialogTitle = _inter(
    20,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static final TextStyle brandLarge = _inter(
    22,
    FontWeight.w700,
    color: AppColors.textPrimary,
  );
}
