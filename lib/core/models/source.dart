import 'package:equatable/equatable.dart';

class Source extends Equatable {
  const Source({
    required this.id,
    required this.name,
    required this.kind,
    required this.openingBalance,
    this.isActive = true,
    this.openingDate,
    this.bankAccountId,
    this.bankAccountName,
  });

  final String id;
  final String name;
  final String kind;
  final double openingBalance;

  /// Archived sources are inactive and are not offered for new entries.
  final bool isActive;

  /// Entries before this date are not counted. Null in sample data.
  final DateTime? openingDate;

  /// The bank account this source's money is kept in.
  final String? bankAccountId;
  final String? bankAccountName;

  Source copyWith({
    bool? isActive,
    String? bankAccountId,
    String? bankAccountName,
  }) => Source(
    id: id,
    name: name,
    kind: kind,
    openingBalance: openingBalance,
    isActive: isActive ?? this.isActive,
    openingDate: openingDate,
    bankAccountId: bankAccountId ?? this.bankAccountId,
    bankAccountName: bankAccountName ?? this.bankAccountName,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    kind,
    openingBalance,
    isActive,
    openingDate,
    bankAccountId,
    bankAccountName,
  ];
}
