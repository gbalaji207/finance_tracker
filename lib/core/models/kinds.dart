import 'package:finance_tracker/core/models/tx_type.dart';

/// The kinds a source can have (the database allows exactly these).
const kSourceKinds = ['Employment', 'Freelance', 'Rental', 'Other'];

/// The kinds a category can have; income has none.
const kCategoryKinds = [
  TxType.expense,
  TxType.investment,
  TxType.savings,
  TxType.partner,
];
