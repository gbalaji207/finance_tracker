import 'package:finance_tracker/core/config/app_config.dart';
import 'package:finance_tracker/core/models/category.dart';
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

/// Adds a category, or renames one when [editing] is set (its kind is shown
/// but cannot change). Meant to sit inside a [SideDrawer]; [onClose] closes it
/// after a save or a cancel.
class CategoryForm extends StatefulWidget {
  const CategoryForm({
    super.key,
    required this.onSave,
    required this.onClose,
    this.editing,
  });

  /// The category being renamed; null when adding.
  final Category? editing;

  /// Saves the category. Resolves to an error message, or null on success.
  final Future<String?> Function(CategoryInput input) onSave;

  final VoidCallback onClose;

  @override
  State<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<CategoryForm> {
  late final TextEditingController _name;
  late TxType _kind;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.editing?.name ?? '');
    _kind = widget.editing?.kind ?? TxType.expense;
  }

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
    AppSnack.info(
      context,
      AppConfig.note(_isEditing ? 'Category renamed' : 'Category saved'),
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
            _isEditing ? 'Rename category' : 'New category',
            style: AppTextStyles.sectionTitle,
          ),
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
          helperText: _isEditing
              ? 'The kind cannot be changed: entries already use it.'
              : null,
          value: _kind,
          items: [for (final k in kCategoryKinds) AppDropdownItem(k, k.label)],
          // Locked while renaming.
          onChanged: _isEditing
              ? null
              : (v) {
                  if (v != null) setState(() => _kind = v);
                },
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            AppButton(
              label: _isEditing ? 'Save changes' : 'Save category',
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
