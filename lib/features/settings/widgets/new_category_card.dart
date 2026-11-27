import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class NewCategoryCard extends StatefulWidget {
  const NewCategoryCard({super.key, required this.onSave});

  final VoidCallback onSave;

  @override
  State<NewCategoryCard> createState() => _NewCategoryCardState();
}

class _NewCategoryCardState extends State<NewCategoryCard> {
  /// Categories belong to expense, investment or savings; never income.
  static const _kinds = [TxType.expense, TxType.investment, TxType.savings];

  final _name = TextEditingController();
  TxType _kind = TxType.expense;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 14,
        children: [
          Text('New category', style: AppTextStyles.sectionTitle),
          AppTextField(
            label: 'Name',
            hintText: 'e.g. Insurance',
            controller: _name,
          ),
          AppDropdown<TxType>(
            label: 'Kind',
            value: _kind,
            items: [for (final k in _kinds) AppDropdownItem(k, k.label)],
            onChanged: (v) {
              if (v != null) setState(() => _kind = v);
            },
          ),
          AppButton(
            label: 'Save category',
            size: AppButtonSize.large,
            expand: true,
            onPressed: widget.onSave,
          ),
        ],
      ),
    );
  }
}
