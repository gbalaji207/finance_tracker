import 'package:finance_tracker/core/models/category.dart';
import 'package:finance_tracker/core/models/entry_template.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_colors.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/theme/app_text_styles.dart';
import 'package:finance_tracker/core/widgets/app_button.dart';
import 'package:finance_tracker/core/widgets/app_card.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:finance_tracker/core/widgets/app_text_field.dart';
import 'package:finance_tracker/core/widgets/type_selector.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_cubit.dart';
import 'package:finance_tracker/features/transactions/cubit/add_entry_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEntryPanel extends StatefulWidget {
  const AddEntryPanel({
    super.key,
    required this.templates,
    required this.sourceName,
    required this.sources,
    required this.categories,
  });

  final List<EntryTemplate> templates;
  final String Function(String sourceId) sourceName;
  final List<Source> sources;
  final List<Category> categories;

  @override
  State<AddEntryPanel> createState() => _AddEntryPanelState();
}

class _AddEntryPanelState extends State<AddEntryPanel> {
  final _amount = TextEditingController();
  final _description = TextEditingController();

  /// The template last chosen in the "Fill from template" dropdown.
  String? _templateId;

  @override
  void dispose() {
    _amount.dispose();
    _description.dispose();
    super.dispose();
  }

  void _applyTemplate(String? id) {
    if (id == null) return;
    final template = widget.templates.firstWhere((t) => t.id == id);
    final applied = context.read<AddEntryCubit>().applyTemplate(template);
    setState(() => _templateId = id);
    _amount.text = applied.amount?.toStringAsFixed(0) ?? '';
    _description.text = applied.description;
  }

  void _save() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Saved (sample data, nothing is stored yet)'),
        ),
      );
    context.read<AddEntryCubit>().reset();
    _amount.clear();
    _description.clear();
    setState(() => _templateId = null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddEntryCubit, AddEntryState>(
      builder: (context, state) {
        final cubit = context.read<AddEntryCubit>();
        final categories =
            widget.categories.where((c) => c.kind == state.type).toList();
        return AppCard(
          borderColor: AppColors.primary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 14,
            children: [
              Text('New entry', style: AppTextStyles.sectionTitle),
              TypeSelector(
                label: 'Type',
                value: state.type,
                onChanged: cubit.selectType,
              ),
              AppDropdown<String>(
                label: 'Fill from template (optional)',
                hintText: 'Choose a template…',
                value: _templateId,
                items: [
                  for (final t in widget.templates)
                    AppDropdownItem(
                      t.id,
                      '${t.name} · ${widget.sourceName(t.sourceId)}',
                    ),
                ],
                onChanged: _applyTemplate,
              ),
              AppDropdown<String>(
                label: 'Source',
                value: state.sourceId,
                items: [
                  for (final s in widget.sources) AppDropdownItem(s.id, s.name),
                ],
                onChanged: (v) {
                  if (v != null) cubit.selectSource(v);
                },
              ),
              if (state.type != TxType.income)
                AppDropdown<String>(
                  label: 'Category',
                  helperText: 'Hidden for income entries.',
                  value: state.categoryId,
                  items: [
                    for (final c in categories) AppDropdownItem(c.id, c.name),
                  ],
                  onChanged: cubit.selectCategory,
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s12,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Amount (₹)',
                      hintText: '0',
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child: AppDateField(
                      label: 'Date',
                      value: state.date,
                      onChanged: cubit.selectDate,
                    ),
                  ),
                ],
              ),
              AppTextField(
                label: 'Description',
                hintText: 'Where it went, e.g. SBI FD',
                controller: _description,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: AppSpacing.s8,
                children: [
                  AppButton(
                    label: 'Save entry',
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: _save,
                  ),
                  AppButton(
                    label: 'Save and add another',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.large,
                    expand: true,
                    onPressed: _save,
                  ),
                ],
              ),
              Text(
                'Keyboard: N new entry · Enter save · Esc close',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        );
      },
    );
  }
}
