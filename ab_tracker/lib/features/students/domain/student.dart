class Student {
  final int? id;
  final int groupId;
  final String massar;
  final String firstName;
  final String lastName;
  final String? email;

  const Student({
    this.id,
    required this.groupId,
    required this.massar,
    required this.firstName,
    required this.lastName,
    this.email,
  });

  String get fullName => '$firstName $lastName';
}
