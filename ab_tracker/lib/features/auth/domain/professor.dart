class Professor {
  final int? id;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? email;

  const Professor({
    this.id,
    required this.username,
    this.firstName,
    this.lastName,
    this.email,
  });

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      id: map['id'],
      username: map['username'] ?? '',
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };
  }
}
