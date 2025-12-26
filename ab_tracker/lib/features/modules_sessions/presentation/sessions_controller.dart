import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/db/app_database.dart';
import '../data/module_local_ds.dart';
import '../data/module_repo_impl.dart';
import '../data/session_local_ds.dart';
import '../data/session_repo_impl.dart';
import '../domain/module.dart';
import '../domain/session.dart';

class SessionsState {
  final List<ModuleEntity> modules;
  final List<SessionEntity> sessions;
  final int? moduleFilterId;
  final String? dateFilter;
  final String query;

  const SessionsState({
    required this.modules,
    required this.sessions,
    required this.moduleFilterId,
    required this.dateFilter,
    required this.query,
  });
}

final sessionsControllerProvider =
    AsyncNotifierProvider<SessionsController, SessionsState>(
        SessionsController.new);

class SessionsController extends AsyncNotifier<SessionsState> {
  String _query = '';
  int? _moduleId;
  String? _date;

  late final AppDatabase _db;

  @override
  Future<SessionsState> build() async {
    _db = AppDatabase.instance;

    final moduleRepo = ModuleRepoImpl(ModuleLocalDS(_db));
    final modules = await moduleRepo.getAll();

    final sessionRepo = SessionRepoImpl(SessionLocalDS(_db));
    final sessions = await sessionRepo.getAll(
        query: _query, moduleId: _moduleId, date: _date);

    return SessionsState(
      modules: modules,
      sessions: sessions,
      moduleFilterId: _moduleId,
      dateFilter: _date,
      query: _query,
    );
  }

  void setQuery(String q) {
    _query = q;
    ref.invalidateSelf();
  }

  void setModuleFilter(int? id) {
    _moduleId = id;
    ref.invalidateSelf();
  }

  void setDateFilter(String? dateIso) {
    _date = dateIso;
    ref.invalidateSelf();
  }

  Future<void> upsert(SessionEntity s) async {
    final repo = SessionRepoImpl(SessionLocalDS(_db));
    await repo.upsert(s);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    final repo = SessionRepoImpl(SessionLocalDS(_db));
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
