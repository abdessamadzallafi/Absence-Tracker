import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/attendance.dart';
import '../attendance_providers.dart';

final dashboardControllerProvider = FutureProvider<GlobalStats>((ref) async {
  final uc = ref.watch(getGlobalStatsProvider);
  return uc();
});
