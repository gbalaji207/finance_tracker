import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/side_drawer.dart';
import 'package:flutter/material.dart';

/// Adds a bank account, or renames one when [editing] is set. Meant to sit
/// inside a [SideDrawer]; [onClose] closes it after a save or a cancel.
class BankAccountForm extends StatefulWidget {
  const BankAccountForm({
    super.key,
    required this.onSave,
    required this.onClose,
    this.editing,
  });

  /// The account being renamed; null when adding.
  final BankAccount? editing;

  /// Saves the account. Resolves to an error message, or null on success.
  final Future<String?> Function(String name) onSave;

  final VoidCallback onClose;

  @override
  State<BankAccountForm> createState() => _BankAccountFormState();
}

class _BankAccountFormState extends State<BankAccountForm> {
  late final TextEditingController _name;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.editing?.name ?? '');
  }

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
    AppSnack.info(
      context,
      AppConfig.note(
        _isEditing ? 'Bank account renamed' : 'Bank account saved',
      ),
    );
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Padding(
          padding: SideDrawer.titleGap,
          child: Text(
            _isEditing ? 'Rename bank account' : 'New bank account',
            style: AppTextStyles.sectionTitle,
          ),
        ),
        AppTextField(
          label: 'Name',
          hintText: 'e.g. HDFC Salary',
          helperText: 'Use a name you will recognise from your bank statement.',
          controller: _name,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            AppButton(
              label: _isEditing ? 'Save changes' : 'Save bank account',
              size: AppButtonSize.large,
              expand: true,
              onPressed: _saving ? null : _save,
            ),
            AppButton(
              label: 'Cancel',
              variant: AppButtonVariant.secondary,
              size: AppButtonSize.large,
              expand: true,
              onPressed: _saving ? null : widget.onClose,
            ),
          ],
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
    );
  }
}
