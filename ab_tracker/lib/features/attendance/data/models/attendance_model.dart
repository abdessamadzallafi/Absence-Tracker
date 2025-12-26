import '../../domain/attendance.dart';

class AttendanceModel {
  final int? id;
  final int sessionId;
  final int studentId;
  final AttendanceStatus status;
  final String? note;

  const AttendanceModel({
    this.id,
    required this.sessionId,
    required this.studentId,
    required this.status,
    this.note,
  });

  factory AttendanceModel.fromMap(Map<String, Object?> map) => AttendanceModel(
        id: map['id'] as int?,
        sessionId: map['sessionId'] as int,
        studentId: map['studentId'] as int,
        status: AttendanceStatus.values
            .firstWhere((e) => e.name == (map['status'] as String)),
        note: map['note'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'sessionId': sessionId,
        'studentId': studentId,
        'status': status.name,
        'note': note,
      };
}
