import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/kinds.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/source_input.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/entry_validation.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/side_drawer.dart';
import 'package:flutter/material.dart';

/// Adds a source, or changes one when [editing] is set. Meant to sit inside a
/// [SideDrawer]; [onClose] closes it after a save or a cancel.
class SourceForm extends StatefulWidget {
  const SourceForm({
    super.key,
    required this.bankAccounts,
    required this.onSave,
    required this.onClose,
    this.editing,
  });

  /// The accounts to choose from: the active ones, plus the edited source's
  /// current account.
  final List<BankAccount> bankAccounts;

  /// The source being edited; null when adding.
  final Source? editing;

  /// Saves the source. Resolves to an error message, or null on success.
  final Future<String?> Function(SourceInput input) onSave;

  final VoidCallback onClose;

  @override
  State<SourceForm> createState() => _SourceFormState();
}

class _SourceFormState extends State<SourceForm> {
  late final TextEditingController _name;
  late final TextEditingController _opening;
  late String _kind;
  String? _bankAccountId;
  late DateTime _openingDate;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _name = TextEditingController(text: e?.name ?? '');
    _opening = TextEditingController(
      text: e == null ? '' : e.openingBalance.toStringAsFixed(0),
    );
    _kind = e?.kind ?? 'Rental';
    _bankAccountId = e?.bankAccountId;
    _openingDate = e?.openingDate ?? appToday();
  }

  /// The chosen account, or the first one while none is chosen (or the chosen
  /// one is no longer offered).
  String? get _accountId {
    final accounts = widget.bankAccounts;
    if (accounts.isEmpty) return null;
    if (accounts.any((a) => a.id == _bankAccountId)) return _bankAccountId;
    return accounts.first.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_error != null) setState(() => _error = null);
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter a name.');
      return;
    }
    final accountId = _accountId;
    if (accountId == null) {
      setState(() => _error = 'Add a bank account first.');
      return;
    }
    // An empty opening balance means 0.
    final text = _opening.text.trim();
    final opening = text.isEmpty ? 0.0 : parseAmount(text);
    if (opening == null) {
      setState(
        () => _error = 'Opening balance must be a number (use 0 if none).',
      );
      return;
    }
    setState(() => _saving = true);
    final error = await widget.onSave(
      SourceInput(
        name: _name.text.trim(),
        kind: _kind,
        openingBalance: opening,
        openingDate: _openingDate,
        bankAccountId: accountId,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(
      context,
      AppConfig.note(_isEditing ? 'Source updated' : 'Source saved'),
    );
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.bankAccounts;
    final movesAccount =
        _isEditing &&
        _accountId != null &&
        _accountId != widget.editing!.bankAccountId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 14,
      children: [
        Padding(
          padding: SideDrawer.titleGap,
          child: Text(
            _isEditing ? 'Edit source' : 'New source',
            style: AppTextStyles.sectionTitle,
          ),
        ),
        AppTextField(
          label: 'Name',
          hintText: 'e.g. Aqua 410',
          controller: _name,
          onChanged: (_) => _clearError(),
        ),
        AppDropdown<String>(
          label: 'Kind',
          value: _kind,
          items: [for (final k in kSourceKinds) AppDropdownItem(k, k)],
          onChanged: (v) {
            if (v != null) setState(() => _kind = v);
          },
        ),
        AppDropdown<String>(
          label: 'Bank account',
          helperText: "The account where this source's money is kept.",
          value: _accountId,
          items: [for (final a in accounts) AppDropdownItem(a.id, a.name)],
          onChanged: accounts.isEmpty
              ? null
              : (v) {
                  if (v != null) {
                    setState(() {
                      _bankAccountId = v;
                      _error = null;
                    });
                  }
                },
        ),
        if (movesAccount)
          Text(
            "All of this source's past entries move to the new account, "
            "so both accounts' totals change.",
            style: AppTextStyles.caption,
          ),
        AppTextField(
          label: 'Opening balance (₹)',
          hintText: '0',
          helperText:
              'Balance of this source on the day you start using the app.',
          controller: _opening,
          onChanged: (_) => _clearError(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        if (_isEditing)
          Text(
            "Changing this changes the source's balance for every month.",
            style: AppTextStyles.caption,
          ),
        AppDateField(
          label: 'Opening date',
          helperText: 'Entries before this date are not counted.',
          value: _openingDate,
          onChanged: (d) => setState(() => _openingDate = d),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            AppButton(
              label: _isEditing ? 'Save changes' : 'Save source',
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
