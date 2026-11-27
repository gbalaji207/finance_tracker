import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class NewBankAccountCard extends StatefulWidget {
  const NewBankAccountCard({super.key, required this.onSave});

  /// Saves the account. Resolves to an error message, or null on success.
  final Future<String?> Function(String name) onSave;

  @override
  State<NewBankAccountCard> createState() => _NewBankAccountCardState();
}

class _NewBankAccountCardState extends State<NewBankAccountCard> {
  final _name = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a name.');
      return;
    }
    setState(() => _saving = true);
    final error = await widget.onSave(name);
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(context, AppConfig.note('Bank account saved'));
    _name.clear();
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text('New bank account', style: AppTextStyles.sectionTitle),
          AppTextField(
            label: 'Name',
            hintText: 'e.g. HDFC Salary',
            helperText:
                'Use a name you will recognise from your bank statement.',
            controller: _name,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
          AppButton(
            label: 'Save bank account',
            size: AppButtonSize.large,
            expand: true,
            onPressed: _saving ? null : _save,
          ),
          if (_error != null)
            Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
