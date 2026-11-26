import 'package:equatable/equatable.dart';

class Source extends Equatable {
  const Source({
    required this.id,
    required this.name,
    required this.kind,
    required this.openingBalance,
  });

  final String id;
  final String name;
  final String kind;
  final double openingBalance;

  @override
  List<Object?> get props => [id, name, kind, openingBalance];
}
