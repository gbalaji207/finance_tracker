import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/category.dart';

class CategoryUsage extends Equatable {
  const CategoryUsage({required this.category, required this.entryCount});

  final Category category;
  final int entryCount;

  @override
  List<Object?> get props => [category, entryCount];
}
