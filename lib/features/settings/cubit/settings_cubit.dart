import 'package:finance_tracker/core/data/finance_repository.dart';
import 'package:finance_tracker/core/models/load_status.dart';
import 'package:finance_tracker/features/settings/cubit/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._repo) : super(const SettingsState());

  final FinanceRepository _repo;

  Future<void> load() async {
    final sources = await _repo.allSources();
    final usage = await _repo.categoryUsage();
    emit(
      state.copyWith(
        status: LoadStatus.loaded,
        sources: sources,
        categoryUsage: usage,
      ),
    );
  }

  /// Archives an active source or restores an archived one. Lives in memory
  /// only and resets on reload.
  void toggleSourceActive(String id) {
    emit(
      state.copyWith(
        sources: [
          for (final s in state.sources)
            if (s.id == id) s.copyWith(isActive: !s.isActive) else s,
        ],
      ),
    );
  }
}
