import 'package:equatable/equatable.dart';

class BankReconciliation extends Equatable {
  const BankReconciliation({
    required this.sourcesTotal,
    required this.bankBalance,
    required this.asOf,
  });

  final double sourcesTotal;
  final double bankBalance;
  final DateTime asOf;

  double get difference => sourcesTotal - bankBalance;

  @override
  List<Object?> get props => [sourcesTotal, bankBalance, asOf];
}
