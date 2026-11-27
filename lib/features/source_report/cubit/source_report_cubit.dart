import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/core/utils/error_message.dart';
import 'package:finance_tracker/features/source_report/cubit/source_report_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SourceReportCubit extends Cubit<SourceReportState> {
  SourceReportCubit(this._repo) : super(const SourceReportState());

  final FinanceRepository _repo;
  int _request = 0;

  Future<void> load() async {
    final request = ++_request;
    emit(state.copyWith(status: LoadStatus.loading, clearError: true));
    try {
      final sources = await _repo.allSources();
      // The current choice, else the first active source, else the first one.
      String? id = state.selectedSourceId;
      if (id == null || !sources.any((s) => s.id == id)) {
        final active = sources.where((s) => s.isActive);
        id = active.isNotEmpty
            ? active.first.id
            : (sources.isNotEmpty ? sources.first.id : null);
      }
      final report = id == null ? null : await _repo.sourceReport(id);
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.loaded,
          sources: sources,
          selectedSourceId: id,
          report: report,
          clearReport: report == null,
        ),
      );
    } catch (e) {
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(
          status: LoadStatus.error,
          errorMessage: friendlyError(e),
        ),
      );
    }
  }

  /// Keeps the old report on screen until the new one arrives. A failure goes
  /// back to the previous source and shows a SnackBar.
  Future<void> select(String id) async {
    final previous = state.selectedSourceId;
    final request = ++_request;
    emit(state.copyWith(selectedSourceId: id));
    try {
      final report = await _repo.sourceReport(id);
      if (request != _request || isClosed) return;
      emit(state.copyWith(report: report));
    } catch (e) {
      if (request != _request || isClosed) return;
      emit(
        state.copyWith(
          selectedSourceId: previous,
          actionError: friendlyError(e),
        ),
      );
    }
  }

  void clearActionError() => emit(state.copyWith(clearActionError: true));
}
