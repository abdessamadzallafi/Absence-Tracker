class AppDateUtils {
  static String todayIso() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  static bool isIsoDate(String v) {
    final r = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!r.hasMatch(v)) return false;
    try {
      final parts = v.split('-').map(int.parse).toList();
      DateTime(parts[0], parts[1], parts[2]);
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool isTimeHHmm(String v) {
    final r = RegExp(r'^\d{2}:\d{2}$');
    if (!r.hasMatch(v)) return false;
    final parts = v.split(':').map(int.parse).toList();
    final h = parts[0], m = parts[1];
    return h >= 0 && h <= 23 && m >= 0 && m <= 59;
  }
}
