import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/source.dart';
import 'package:finance_tracker/core/models/tx_type.dart';
import 'package:finance_tracker/core/theme/app_spacing.dart';
import 'package:finance_tracker/core/widgets/app_date_field.dart';
import 'package:finance_tracker/core/widgets/app_dropdown.dart';
import 'package:flutter/material.dart';

/// From, To, Bank account, Source and Type. Picking a From after To moves To
/// to the same day, and a To before From moves From. [sources] is already
/// limited to the chosen bank account.
class LedgerFilters extends StatelessWidget {
  const LedgerFilters({
    super.key,
    required this.from,
    required this.to,
    required this.bankAccounts,
    required this.sources,
    required this.bankAccountFilter,
    required this.sourceFilter,
    required this.typeFilter,
    required this.onRangeChanged,
    required this.onBankAccountChanged,
    required this.onSourceChanged,
    required this.onTypeChanged,
  });

  final DateTime from;
  final DateTime to;
  final List<BankAccount> bankAccounts;
  final List<Source> sources;
  final String? bankAccountFilter;
  final String? sourceFilter;
  final TxType? typeFilter;
  final void Function(DateTime from, DateTime to) onRangeChanged;
  final ValueChanged<String?> onBankAccountChanged;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<TxType?> onTypeChanged;

  /// Sentinel for "all": a dropdown item with a null value does not show as
  /// selected, so "all" is a real value that is mapped back to null.
  static const _all = 'all';

  @override
  Widget build(BuildContext context) {
    final fields = <Widget>[
      AppDateField(
        label: 'From',
        value: from,
        onChanged: (d) => onRangeChanged(d, d.isAfter(to) ? d : to),
      ),
      AppDateField(
        label: 'To',
        value: to,
        onChanged: (d) => onRangeChanged(d.isBefore(from) ? d : from, d),
      ),
      AppDropdown<String>(
        label: 'Bank account',
        value: bankAccountFilter ?? _all,
        items: [
          const AppDropdownItem(_all, 'All accounts'),
          for (final a in bankAccounts)
            AppDropdownItem(a.id, a.isActive ? a.name : '${a.name} (archived)'),
        ],
        onChanged: (v) =>
            onBankAccountChanged(v == null || v == _all ? null : v),
      ),
      AppDropdown<String>(
        label: 'Source',
        value: sourceFilter ?? _all,
        items: [
          const AppDropdownItem(_all, 'All sources'),
          for (final s in sources)
            AppDropdownItem(s.id, s.isActive ? s.name : '${s.name} (archived)'),
        ],
        onChanged: (v) => onSourceChanged(v == null || v == _all ? null : v),
      ),
      AppDropdown<String>(
        label: 'Type',
        value: typeFilter?.name ?? _all,
        items: [
          const AppDropdownItem(_all, 'All types'),
          for (final t in TxType.values) AppDropdownItem(t.name, t.label),
        ],
        onChanged: (v) => onTypeChanged(
          v == null || v == _all ? null : TxType.values.byName(v),
        ),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Five fields in a row need about 860px; below that they stack.
        if (constraints.maxWidth >= 860) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppSpacing.s12,
            children: [for (final f in fields) Expanded(child: f)],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s12,
          children: fields,
        );
      },
    );
  }
}
