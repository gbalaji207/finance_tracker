import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class NewSourceCard extends StatefulWidget {
  const NewSourceCard({super.key, required this.onSave});

  final VoidCallback onSave;

  @override
  State<NewSourceCard> createState() => _NewSourceCardState();
}

class _NewSourceCardState extends State<NewSourceCard> {
  static const _kinds = ['Employment', 'Freelance', 'Rental', 'Other'];

  final _name = TextEditingController();
  final _opening = TextEditingController();
  String _kind = 'Rental';

  @override
  void dispose() {
    _name.dispose();
    _opening.dispose();
    super.dispose();
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          AppButton(
            label: 'Save source',
            size: AppButtonSize.large,
            expand: true,
            onPressed: widget.onSave,
          ),
        ],
      ),
    );
  }
}
