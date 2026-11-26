import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/money.dart';
import 'package:flutter/material.dart';

class DesignSystemPreview extends StatelessWidget {
  const DesignSystemPreview({super.key});

  static const _colors = <String, Color>{
    'pageBg': AppColors.pageBg,
    'surface': AppColors.surface,
    'cardBorder': AppColors.cardBorder,
    'divider': AppColors.divider,
    'inputBorder': AppColors.inputBorder,
    'controlBorder': AppColors.controlBorder,
    'track': AppColors.track,
    'navHover': AppColors.navHover,
    'textPrimary': AppColors.textPrimary,
    'textSecondary': AppColors.textSecondary,
    'primary': AppColors.primary,
    'primaryDark': AppColors.primaryDark,
    'primaryTint': AppColors.primaryTint,
    'income': AppColors.income,
    'incomeBg': AppColors.incomeBg,
    'expenseFg': AppColors.expenseFg,
    'expenseBg': AppColors.expenseBg,
    'investmentFg': AppColors.investmentFg,
    'investmentBg': AppColors.investmentBg,
    'savingsFg': AppColors.savingsFg,
    'savingsBg': AppColors.savingsBg,
    'chartIncome': AppColors.chartIncome,
    'chartExpense': AppColors.chartExpense,
  };

  static final _textStyles = <String, TextStyle>{
    'pageTitle': AppTextStyles.pageTitle,
    'brand': AppTextStyles.brand,
    'sectionTitle': AppTextStyles.sectionTitle,
    'cardTitle': AppTextStyles.cardTitle,
    'body': AppTextStyles.body,
    'bodyStrong': AppTextStyles.bodyStrong,
    'bodySecondary': AppTextStyles.bodySecondary,
    'subtitle': AppTextStyles.subtitle,
    'rowLabel': AppTextStyles.rowLabel,
    'rowValue': AppTextStyles.rowValue,
    'caption': AppTextStyles.caption,
    'label': AppTextStyles.label,
    'captionBold': AppTextStyles.captionBold,
    'kpiValue': AppTextStyles.kpiValue,
    'balanceValue': AppTextStyles.balanceValue,
    'summaryValue': AppTextStyles.summaryValue,
    'button': AppTextStyles.button,
    'buttonSmall': AppTextStyles.buttonSmall,
    'link': AppTextStyles.link,
    'badge': AppTextStyles.badge,
    'navItem': AppTextStyles.navItem,
    'navItemActive': AppTextStyles.navItemActive,
  };

  static String _hex(Color c) =>
      '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s32,
          children: [
            _section('Colors', [
              Wrap(
                spacing: AppSpacing.s12,
                runSpacing: AppSpacing.s12,
                children: [
                  for (final e in _colors.entries) _swatch(e.key, e.value),
                ],
              ),
            ]),
            _section('Typography', [
              for (final e in _textStyles.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.s8),
                  child: Text(e.key, style: e.value),
                ),
            ]),
            _section('Type badges', [
              Wrap(
                spacing: AppSpacing.s8,
                children: [
                  for (final t in TxType.values)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.s4,
                        horizontal: AppSpacing.s8,
                      ),
                      decoration: BoxDecoration(
                        color: t.badgeBg,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusBadge),
                      ),
                      child: Text(
                        t.label,
                        style: AppTextStyles.badge.copyWith(color: t.badgeFg),
                      ),
                    ),
                ],
              ),
            ]),
            _section('Money', [
              _moneyRow('Money.plain(132400)', Money.plain(132400)),
              _moneyRow('Money.signed(45000, income)',
                  Money.signed(45000, TxType.income)),
              _moneyRow('Money.signed(32000, expense)',
                  Money.signed(32000, TxType.expense)),
              _moneyRow('Money.plain(0)', Money.plain(0)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s12,
        children: [
          Text(title, style: AppTextStyles.pageTitle),
          ...children,
        ],
      );

  Widget _swatch(String name, Color color) => SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s4,
          children: [
            Container(
              width: 120,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
                border: Border.all(color: AppColors.cardBorder),
              ),
            ),
            Text(name, style: AppTextStyles.captionBold),
            Text(_hex(color), style: AppTextStyles.caption),
          ],
        ),
      );

  Widget _moneyRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.s4),
        child: Row(
          spacing: AppSpacing.s16,
          children: [
            SizedBox(
              width: 260,
              child: Text(label, style: AppTextStyles.bodySecondary),
            ),
            Text(value, style: AppTextStyles.bodyStrong),
          ],
        ),
      );
}
