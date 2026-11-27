import 'package:equatable/equatable.dart';

/// A bank account. Every source belongs to exactly one.
class BankAccount extends Equatable {
  const BankAccount({
    required this.id,
    required this.name,
    this.isActive = true,
  });

  final String id;
  final String name;

  /// Archived accounts are not offered for new sources.
  final bool isActive;

  @override
  List<Object?> get props => [id, name, isActive];
}

/// A bank account with how many active sources it has (the Settings list).
class BankAccountUsage extends Equatable {
  const BankAccountUsage({
    required this.account,
    required this.activeSourceCount,
  });

  final BankAccount account;
  final int activeSourceCount;

  @override
  List<Object?> get props => [account, activeSourceCount];
}
