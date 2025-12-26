import '../../domain/group.dart';

class GroupModel extends Group {
  const GroupModel({super.id, required super.name, required super.filiere});

  factory GroupModel.fromMap(Map<String, Object?> map) => GroupModel(
        id: map['id'] as int?,
        name: map['name'] as String,
        filiere: map['filiere'] as String,
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'name': name,
        'filiere': filiere,
      };
}
