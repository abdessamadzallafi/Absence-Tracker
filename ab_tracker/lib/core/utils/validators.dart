class Validators {
  static String? requiredText(String? v, {String msg = 'Champ obligatoire'}) {
    if (v == null || v.trim().isEmpty) return msg;
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!r.hasMatch(v.trim())) return 'Email invalide';
    return null;
  }
}
