class UserModel {
  int? id;

  String name;

  String nim;

  String phone;

  String password;

  String role;

  UserModel({
    this.id,

    required this.name,

    required this.nim,

    required this.phone,

    required this.password,

    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],

      name: map["name"] ?? "",

      nim: map["nim"] ?? map["email"] ?? "",

      phone: map["phone"] ?? "",

      password: map["password"] ?? "",

      role: map["role"] ?? "USER",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,

      "name": name,

      "nim": nim,

      "phone": phone,

      "password": password,

      "role": role.toUpperCase(),
    };
  }
}
