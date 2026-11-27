import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:flutter/painting.dart';

enum TxType {
  income,
  expense,
  investment,
  savings,
  partner;

  String get label => switch (this) {
    income => 'Income',
    expense => 'Expense',
    investment => 'Investment',
    savings => 'Savings',
    partner => 'Jillu',
  };

  Color get badgeBg => switch (this) {
    income => AppColors.incomeBg,
    expense => AppColors.expenseBg,
    investment => AppColors.investmentBg,
    savings => AppColors.savingsBg,
    partner => AppColors.partnerBg,
  };

  Color get badgeFg => switch (this) {
    income => AppColors.income,
    expense => AppColors.expenseFg,
    investment => AppColors.investmentFg,
    savings => AppColors.savingsFg,
    partner => AppColors.partnerFg,
  };
}
