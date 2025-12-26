enum AttendanceStatus { present, absent, justified }

class GlobalStats {
  final int present;
  final int absent;
  final int justified;

  const GlobalStats(
      {required this.present, required this.absent, required this.justified});

  int get total => present + absent + justified;
  double get presenceRate => total == 0 ? 0 : (present / total) * 100;
}

class StudentHistoryRow {
  final String moduleName;
  final int absent;
  final int justified;
  final List<String> dates; // yyyy-MM-dd

  const StudentHistoryRow({
    required this.moduleName,
    required this.absent,
    required this.justified,
    required this.dates,
  });
}
