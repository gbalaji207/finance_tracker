import 'package:equatable/equatable.dart';

/// The values needed to create a source.
class SourceInput extends Equatable {
  const SourceInput({
    required this.name,
    required this.kind,
    required this.openingBalance,
    required this.openingDate,
    required this.bankAccountId,
  });

  final String name;

  /// Employment, Freelance, Rental or Other.
  final String kind;
  final double openingBalance;

  /// Entries before this date are not counted.
  final DateTime openingDate;

  /// The bank account the source's money is kept in.
  final String bankAccountId;

  @override
  List<Object?> get props => [
    name,
    kind,
    openingBalance,
    openingDate,
    bankAccountId,
  ];
}
