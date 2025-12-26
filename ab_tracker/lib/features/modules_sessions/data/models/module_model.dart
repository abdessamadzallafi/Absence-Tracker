import '../../domain/module.dart';

class ModuleModel extends ModuleEntity {
  const ModuleModel(
      {super.id,
      required super.name,
      required super.semester,
      required super.groupId});

  factory ModuleModel.fromMap(Map<String, Object?> map) => ModuleModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        semester: map['semester'] as String,
        groupId: map['groupId'] as int,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'semester': semester,
        'groupId': groupId,
      };
}
