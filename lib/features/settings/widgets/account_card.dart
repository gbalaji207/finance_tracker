import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:flutter/material.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({
    super.key,
    required this.email,
    required this.onChangePassword,
    required this.onSignOut,
  });

  final String email;
  final VoidCallback onChangePassword;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.s16,
        runSpacing: AppSpacing.s16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Account', style: AppTextStyles.sectionTitle),
              const SizedBox(height: AppSpacing.s6),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Signed in as ',
                      style: AppTextStyles.subtitle,
                    ),
                    TextSpan(
                      text: email,
                      style: AppTextStyles.subtitle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // A Wrap (not a Row) so the buttons drop onto two lines instead of
          // overflowing on a very narrow window.
          Wrap(
            spacing: AppSpacing.s12,
            runSpacing: AppSpacing.s12,
            children: [
              AppButton(
                label: 'Change password',
                variant: AppButtonVariant.secondary,
                onPressed: onChangePassword,
              ),
              AppButton(
                label: 'Sign out',
                variant: AppButtonVariant.secondary,
                onPressed: onSignOut,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
