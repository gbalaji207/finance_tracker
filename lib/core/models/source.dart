import 'package:equatable/equatable.dart';

class Source extends Equatable {
  const Source({
    required this.id,
    required this.name,
    required this.kind,
    required this.openingBalance,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String kind;
  final double openingBalance;

  /// Archived sources are inactive and are not offered for new entries.
  final bool isActive;

  Source copyWith({bool? isActive}) => Source(
        id: id,
        name: name,
        kind: kind,
        openingBalance: openingBalance,
        isActive: isActive ?? this.isActive,
      );

  @override
  List<Object?> get props => [id, name, kind, openingBalance, isActive];
}
