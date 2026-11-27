import 'dart:math' as math;

import 'package:finance_tracker/core/models/monthly_report.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/category_bar_row.dart';
import 'package:finance_tracker/core/widgets/empty_note.dart';
import 'package:flutter/material.dart';

class ExpenseCategoriesCard extends StatelessWidget {
  const ExpenseCategoriesCard({super.key, required this.categories});

  /// Rendered in the order given.
  final List<CategoryTotal> categories;

  @override
  Widget build(BuildContext context) {
    final maxAmount = categories.fold<double>(
      0,
      (m, c) => math.max(m, c.amount),
    );
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s12,
        children: [
          Text('Expenses by category', style: AppTextStyles.sectionTitle),
          if (categories.isEmpty) const EmptyNote('No expenses in this month.'),
          for (final c in categories)
            CategoryBarRow(
              label: c.name,
              amountText: Money.plain(c.amount),
              fraction: maxAmount == 0 ? 0 : c.amount / maxAmount,
            ),
        ],
      ),
    );
  }
}
