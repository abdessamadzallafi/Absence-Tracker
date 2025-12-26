import '../../domain/student.dart';

class StudentModel extends Student {
  const StudentModel({
    super.id,
    required super.groupId,
    required super.massar,
    required super.firstName,
    required super.lastName,
    super.email,
  });

  factory StudentModel.fromMap(Map<String, Object?> map) => StudentModel(
        id: map['id'] as int?,
        groupId: map['groupId'] as int,
        massar: map['massar'] as String,
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        email: map['email'] as String?,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'groupId': groupId,
        'massar': massar,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
      };
}
