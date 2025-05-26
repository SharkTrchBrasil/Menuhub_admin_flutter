class User {
  final int id;
  final String name;
  final String email;



  User({
    required this.id,
    required this.name,
    required this.email,


  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }

  User copyWith({
    int? id,
    String? name,
    String? email,


  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,


    );
  }
}
