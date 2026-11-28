import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/models/category_input.dart';
import 'package:finance_tracker/core/models/kinds.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_snack.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/side_drawer.dart';
import 'package:flutter/material.dart';

/// Adds a category. Meant to sit inside a [SideDrawer]; [onClose] closes it
/// after a save or a cancel. (Categories cannot be edited yet.)
class CategoryForm extends StatefulWidget {
  const CategoryForm({super.key, required this.onSave, required this.onClose});

  /// Saves the category. Resolves to an error message, or null on success.
  final Future<String?> Function(CategoryInput input) onSave;

  final VoidCallback onClose;

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  final _name = TextEditingController();
  TxType _kind = TxType.expense;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Enter a name.');
      return;
    }
    setState(() => _saving = true);
    final error = await widget.onSave(
      CategoryInput(name: _name.text.trim(), kind: _kind),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppSnack.error(context, error);
      return;
    }
    AppSnack.info(context, AppConfig.note('Category saved'));
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
          child: Text('New category', style: AppTextStyles.sectionTitle),
        ),
        AppTextField(
          label: 'Name',
          hintText: 'e.g. Insurance',
          controller: _name,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
        ),
        AppDropdown<TxType>(
          label: 'Kind',
          value: _kind,
          items: [for (final k in kCategoryKinds) AppDropdownItem(k, k.label)],
          onChanged: (v) {
            if (v != null) setState(() => _kind = v);
          },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            AppButton(
              label: 'Save category',
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
