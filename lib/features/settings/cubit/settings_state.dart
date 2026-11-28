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
    this.editingSourceId,
    this.editingBankAccountId,
    this.editingCategoryId,
  });

  final LoadStatus status;

  /// Every bank account with its number of active sources.
  final List<BankAccountUsage> bankAccounts;

  /// Active and archived.
  final List<Source> sources;
  final List<CategoryUsage> categoryUsage;
  final String? errorMessage;

  /// The source, bank account or category being edited; all null when adding.
  final String? editingSourceId;
  final String? editingBankAccountId;
  final String? editingCategoryId;

  /// The accounts a new source can be placed in.
  List<BankAccount> get activeBankAccounts => [
    for (final u in bankAccounts)
      if (u.account.isActive) u.account,
  ];

  /// The source being edited, or null.
  Source? get editingSource {
    final id = editingSourceId;
    if (id == null) return null;
    for (final s in sources) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// The bank account being edited, or null.
  BankAccount? get editingBankAccount {
    final id = editingBankAccountId;
    if (id == null) return null;
    for (final u in bankAccounts) {
      if (u.account.id == id) return u.account;
    }
    return null;
  }

  /// The accounts offered in the source form: the active ones, plus the
  /// account the edited source currently belongs to (even if archived).
  List<BankAccount> get accountsForSourceForm {
    final currentId = editingSource?.bankAccountId;
    return [
      for (final u in bankAccounts)
        if (u.account.isActive || u.account.id == currentId) u.account,
    ];
  }

  SettingsState copyWith({
    LoadStatus? status,
    List<BankAccountUsage>? bankAccounts,
    List<Source>? sources,
    List<CategoryUsage>? categoryUsage,
    String? errorMessage,
    bool clearError = false,
    String? editingSourceId,
    String? editingBankAccountId,
    String? editingCategoryId,
    bool clearEditing = false,
  }) => SettingsState(
    status: status ?? this.status,
    bankAccounts: bankAccounts ?? this.bankAccounts,
    sources: sources ?? this.sources,
    categoryUsage: categoryUsage ?? this.categoryUsage,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    editingSourceId: clearEditing
        ? null
        : (editingSourceId ?? this.editingSourceId),
    editingBankAccountId: clearEditing
        ? null
        : (editingBankAccountId ?? this.editingBankAccountId),
    editingCategoryId: clearEditing
        ? null
        : (editingCategoryId ?? this.editingCategoryId),
  );

  @override
  List<Object?> get props => [
    status,
    bankAccounts,
    sources,
    categoryUsage,
    errorMessage,
    editingSourceId,
    editingBankAccountId,
    editingCategoryId,
  ];
}
