import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/features/source_report/cubit/source_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SourceReportCubit extends Cubit<SourceReportState> {
  SourceReportCubit(this._repo) : super(const SourceReportState());

  final FinanceRepository _repo;

  /// The mock always returns the Aqua 105 report.
  Future<void> load() async {
    final report = await _repo.sourceReport(state.selectedSourceId);
    emit(state.copyWith(status: LoadStatus.loaded, report: report));
  }
}
