import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/bank_account.dart';

/// One bank account: the sum of its sources next to its latest statement
/// balance.
class BankAccountReconciliation extends Equatable {
  const BankAccountReconciliation({
    required this.account,
    required this.sourcesTotal,
    this.bankBalance,
    this.asOf,
  });

  final BankAccount account;

  /// Sum of the balances of this account's sources.
  final double sourcesTotal;

  /// Latest statement balance; null means it was never entered.
  final double? bankBalance;
  final DateTime? asOf;

  bool get isSet => bankBalance != null;

  double? get difference =>
      bankBalance == null ? null : sourcesTotal - bankBalance!;

  bool get matches => difference != null && difference!.abs() < 0.005;

  @override
  List<Object?> get props => [account, sourcesTotal, bankBalance, asOf];
}

/// All bank accounts together (the Dashboard strip).
class BankReconciliation extends Equatable {
  const BankReconciliation(this.accounts);

  final List<BankAccountReconciliation> accounts;

  double get sourcesTotal => accounts.fold(0, (a, e) => a + e.sourcesTotal);

  /// Sum of the balances that have been entered.
  double get bankTotal =>
      accounts.where((e) => e.isSet).fold(0, (a, e) => a + e.bankBalance!);

  int get missingCount => accounts.where((e) => !e.isSet).length;

  int get offCount => accounts.where((e) => e.isSet && !e.matches).length;

  double get offAmount => accounts
      .where((e) => e.isSet && !e.matches)
      .fold(0, (a, e) => a + e.difference!.abs());

  bool get allMatch =>
      accounts.isNotEmpty && missingCount == 0 && offCount == 0;

  @override
  List<Object?> get props => [accounts];
}
