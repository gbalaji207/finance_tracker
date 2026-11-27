import 'package:equatable/equatable.dart';
import 'package:finance_tracker/core/models/bank_account.dart';
import 'package:finance_tracker/core/models/category_usage.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/models/source.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.status = LoadStatus.loading,
    this.bankAccounts = const [],
    this.sources = const [],
    this.categoryUsage = const [],
    this.errorMessage,
  });

  final LoadStatus status;

  /// Every bank account with its number of active sources.
  final List<BankAccountUsage> bankAccounts;

  /// Active and archived.
  final List<Source> sources;
  final List<CategoryUsage> categoryUsage;
  final String? errorMessage;

  /// The accounts a new source can be placed in.
  List<BankAccount> get activeBankAccounts => [
    for (final u in bankAccounts)
      if (u.account.isActive) u.account,
  ];

  SettingsState copyWith({
    LoadStatus? status,
    List<BankAccountUsage>? bankAccounts,
    List<Source>? sources,
    List<CategoryUsage>? categoryUsage,
    String? errorMessage,
    bool clearError = false,
  }) => SettingsState(
    status: status ?? this.status,
    bankAccounts: bankAccounts ?? this.bankAccounts,
    sources: sources ?? this.sources,
    categoryUsage: categoryUsage ?? this.categoryUsage,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );

  @override
  List<Object?> get props => [
    status,
    bankAccounts,
    sources,
    categoryUsage,
    errorMessage,
  ];
}
