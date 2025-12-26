class Group {
  final int? id;
  final String name;
  final String filiere;

  const Group({this.id, required this.name, required this.filiere});

  Group copyWith({int? id, String? name, String? filiere}) => Group(
        id: id ?? this.id,
        name: name ?? this.name,
        filiere: filiere ?? this.filiere,
      );
}
