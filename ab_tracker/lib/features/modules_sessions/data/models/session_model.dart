import '../../domain/session.dart';

class SessionModel extends SessionEntity {
  const SessionModel(
      {super.id,
      required super.moduleId,
      required super.date,
      required super.time,
      required super.type});

  factory SessionModel.fromMap(Map<String, Object?> map) => SessionModel(
        id: map['id'] as int?,
        moduleId: map['moduleId'] as int,
        date: map['date'] as String,
        time: map['time'] as String,
        type: map['type'] as String,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'moduleId': moduleId,
        'date': date,
        'time': time,
        'type': type,
      };
}
