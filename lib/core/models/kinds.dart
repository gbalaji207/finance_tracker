import 'package:finance_tracker/core/models/tx_type.dart';

/// The kinds a source can have (the database allows exactly these).
const kSourceKinds = ['Employment', 'Freelance', 'Rental', 'Loan', 'Other'];

/// Loan sources are left out of the monthly report and the source report.
const kLoanKind = 'Loan';

/// The kinds a category can have; income has none.
const kCategoryKinds = [
  TxType.expense,
  TxType.investment,
  TxType.savings,
  TxType.partner,
];
