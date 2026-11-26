import 'package:flutter/painting.dart';

abstract final class AppColors {
  // Surfaces and lines
  static const pageBg = Color(0xFFF6F6F3);
  static const surface = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE4E4DF);
  static const divider = Color(0xFFEEEEE9);
  static const inputBorder = Color(0xFFC4C4BC);
  static const controlBorder = Color(0xFFD8D8D2);
  static const track = Color(0xFFE9E9E3);
  static const navHover = Color(0xFFEDEDE8);
  // Text
  static const textPrimary = Color(0xFF1F2328);
  static const textSecondary = Color(0xFF5B6168);
  // Brand
  static const primary = Color(0xFF0F766E);
  static const primaryDark = Color(0xFF0B4F49); // text on tinted backgrounds, links
  static const primaryTint = Color(0xFFE2EFEC); // selected nav item, selected segment
  // Money and type colors
  static const income = Color(0xFF14532D); // income amounts, "matches" text
  static const incomeBg = Color(0xFFE3F1E8);
  static const expenseFg = Color(0xFF7A271A);
  static const expenseBg = Color(0xFFF6E6E2);
  static const investmentFg = Color(0xFF1E3A8A);
  static const investmentBg = Color(0xFFE3EBFA);
  static const savingsFg = Color(0xFF6B3F06);
  static const savingsBg = Color(0xFFFAEFD9);
  // Chart
  static const chartIncome = primary;
  static const chartExpense = Color(0xFFE8B04A);
}
