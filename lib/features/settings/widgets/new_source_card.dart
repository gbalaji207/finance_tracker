import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/data/app_clock.dart';
import 'package:finance_tracker/core/models/source_input.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/utils/entry_validation.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class NewSourceCard extends StatefulWidget {
  const NewSourceCard({super.key, required this.onSave});

  /// Saves the source. Resolves to an error message, or null on success.
  final Future<String?> Function(SourceInput input) onSave;

  @override
  State<NewSourceCard> createState() => _NewSourceCardState();
}

class _NewSourceCardState extends State<NewSourceCard> {
  static const _kinds = ['Employment', 'Freelance', 'Rental', 'Other'];

  final _name = TextEditingController();
  final _opening = TextEditingController();
  String _kind = 'Rental';
  DateTime _openingDate = appToday();
  bool _saving = false;
  String? _error;

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
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(context, AppConfig.note('Source saved'));
    _name.clear();
    _opening.clear();
    setState(() {
      _kind = 'Rental';
      _openingDate = appToday();
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text('New source', style: AppTextStyles.sectionTitle),
          AppTextField(
            label: 'Name',
            hintText: 'e.g. Aqua 410',
            controller: _name,
            onChanged: (_) => _clearError(),
          ),
          AppDropdown<String>(
            label: 'Kind',
            value: _kind,
            items: [for (final k in _kinds) AppDropdownItem(k, k)],
            onChanged: (v) {
              if (v != null) setState(() => _kind = v);
            },
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
          AppDateField(
            label: 'Opening date',
            helperText: 'Entries before this date are not counted.',
            value: _openingDate,
            onChanged: (d) => setState(() => _openingDate = d),
          ),
          AppButton(
            label: 'Save source',
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
