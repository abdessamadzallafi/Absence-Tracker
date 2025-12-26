class SessionEntity {
  final int? id;
  final int moduleId;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String type; // cours/td/tp

  const SessionEntity(
      {this.id,
      required this.moduleId,
      required this.date,
      required this.time,
      required this.type});
}
