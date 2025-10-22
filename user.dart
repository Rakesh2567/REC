class User {
  final String id;
  final String name;
  final String email;
  final UserType type;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: UserType.values.firstWhere(
        (e) => e.toString() == 'UserType.${json['type']}',
      ),
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type.toString().split('.').last,
      'avatar': avatar,
    };
  }
}

enum UserType { teacher, student }
