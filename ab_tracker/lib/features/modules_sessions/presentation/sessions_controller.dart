import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_provider.dart';
import '../data/module_remote_ds.dart';
import '../data/module_repo_impl.dart';
import '../data/session_remote_ds.dart';
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

final sessionsProvider =
    AsyncNotifierProvider.autoDispose<SessionsController, SessionsState>(
        SessionsController.new);

class SessionsController extends AutoDisposeAsyncNotifier<SessionsState> {
  String _query = '';
  int? _moduleId;
  String? _date;

  late SessionRepoImpl _sessionRepo;

  @override
  Future<SessionsState> build() async {
    final api = ref.watch(apiClientProvider);

    final moduleRepo = ModuleRepoImpl(ModuleRemoteDS(api));
    final modules = await moduleRepo.getAll();

    _sessionRepo = SessionRepoImpl(SessionRemoteDS(api));
    final sessions = await _sessionRepo.getAll(
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
    await _sessionRepo.upsert(s);
    ref.invalidateSelf();
  }

  Future<void> delete(int id) async {
    await _sessionRepo.delete(id);
    ref.invalidateSelf();
  }
}
