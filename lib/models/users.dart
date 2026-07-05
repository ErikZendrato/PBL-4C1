class UserModel {
  int? id;
  String name;
  String nim;
  String phone;
  String password;
  String role;
  String lab;
  String photo;

  UserModel({
    this.id,
    required this.name,
    required this.nim,
    required this.phone,
    required this.password,
    required this.role,
    this.lab = "",
    this.photo = "",
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map["id"],
      name: map["name"] ?? "",
      nim: map["nim"] ?? map["email"] ?? "",
      phone: map["phone"] ?? "",
      password: map["password"] ?? "",
      role: map["role"] ?? "USER",
      lab: map["lab"] ?? "",
      photo: map["photo"] ?? "",
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
      "lab": lab,
      "photo": photo,
    };
  }
}