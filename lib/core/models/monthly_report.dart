import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/source_summary.dart';

class CategoryTotal extends Equatable {
  const CategoryTotal({required this.name, required this.amount});

  final String name;
  final double amount;

  @override
  List<Object?> get props => [name, amount];
}

class MonthlyReport extends Equatable {
  const MonthlyReport({
    required this.bySource,
    required this.expenseByCategory,
  });

  final List<SourceSummary> bySource;
  final List<CategoryTotal> expenseByCategory;

  double _sum(double Function(SourceSummary s) pick) =>
      bySource.fold(0, (total, s) => total + pick(s));

  double get opening => _sum((s) => s.opening);
  double get income => _sum((s) => s.income);
  double get expense => _sum((s) => s.expense);
  double get invested => _sum((s) => s.invested);
  double get saved => _sum((s) => s.saved);
  double get closing => _sum((s) => s.closing);
  double get partner => _sum((s) => s.partner);

  double get savingsRate => income == 0 ? 0 : (invested + saved) / income;

  @override
  List<Object?> get props => [bySource, expenseByCategory];
}
