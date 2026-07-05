// // import '../database/db_helper.dart';
// // import '../models/users.dart';
// // import 'package:shared_preferences/shared_preferences.dart';

// // class AuthService {
// //   static const String _userIdKey = "session_user_id";
// //   static const String _roleKey = "session_role";

// //   final DBHelper db = DBHelper();

// //   Future<UserModel?> login(String nim, String password, {String? role}) async {
// //     final data = await db.login(nim.trim(), password);

// //     if (data == null) {
// //       return null;
// //     }

// //     final user = UserModel.fromMap(data);

// //     if (role != null && user.role.toUpperCase() != role.toUpperCase()) {
// //       return null;
// //     }

// //     await saveSession(user);

// //     return user;
// //   }

// //   Future<UserModel> register({
// //     required String name,
// //     required String nim,
// //     required String phone,
// //     required String password,
// //   }) async {
// //     final id = await db.register({
// //       "name": name.trim(),
// //       "nim": nim.trim(),
// //       "phone": phone.trim(),
// //       "password": password,
// //       "role": "USER",
// //     });

// //     return UserModel(
// //       id: id,
// //       name: name.trim(),
// //       nim: nim.trim(),
// //       phone: phone.trim(),
// //       password: password,
// //       role: "USER",
// //     );
// //   }

// //   Future<void> saveSession(UserModel user) async {
// //     final prefs = await SharedPreferences.getInstance();

// //     await prefs.setInt(_userIdKey, user.id ?? 0);
// //     await prefs.setString(_roleKey, user.role.toUpperCase());
// //   }

// //   Future<UserModel?> currentUser() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final userId = prefs.getInt(_userIdKey);

// //     if (userId == null || userId == 0) {
// //       return null;
// //     }

// //     final data = await db.getUserById(userId);

// //     if (data == null) {
// //       await logout();
// //       return null;
// //     }

// //     return UserModel.fromMap(data);
// //   }

// //   Future<String?> currentRole() async {
// //     final prefs = await SharedPreferences.getInstance();

// //     return prefs.getString(_roleKey);
// //   }

// //   Future<bool> hasSession() async {
// //     return await currentUser() != null;
// //   }

// //   Future<UserModel?> updateProfile({
// //     required int id,
// //     required String name,
// //     required String nim,
// //     required String phone,
// //     required String password,
// //     required String role,
// //   }) async {
// //     await db.updateUser({
// //       "id": id,
// //       "name": name.trim(),
// //       "nim": nim.trim(),
// //       "phone": phone.trim(),
// //       "password": password,
// //       "role": role.toUpperCase(),
// //     });

// //     final data = await db.getUserById(id);

// //     return data == null ? null : UserModel.fromMap(data);
// //   }

// //   Future<void> logout() async {
// //     final prefs = await SharedPreferences.getInstance();

// //     await prefs.remove(_userIdKey);
// //     await prefs.remove(_roleKey);
// //   }
// // }

// import '../database/db_helper.dart';
// import '../models/users.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   static const String _userIdKey = "session_user_id";
//   static const String _roleKey = "session_role";

//   final DBHelper db = DBHelper();

//   Future<UserModel?> login(String nim, String password, {String? role}) async {
//     final data = await db.login(nim.trim(), password);

//     if (data == null) {
//       return null;
//     }

//     final user = UserModel.fromMap(data);

//     if (role != null && user.role.toUpperCase() != role.toUpperCase()) {
//       return null;
//     }

//     await saveSession(user);

//     return user;
//   }

//   Future<UserModel> register({
//     required String name,
//     required String nim,
//     required String phone,
//     required String password,
//   }) async {
//     final id = await db.register({
//       "name": name.trim(),
//       "nim": nim.trim(),
//       "phone": phone.trim(),
//       "password": password,
//       "role": "USER",
//       "lab": "",
//     });

//     return UserModel(
//       id: id,
//       name: name.trim(),
//       nim: nim.trim(),
//       phone: phone.trim(),
//       password: password,
//       role: "USER",
//       lab: "",
//     );
//   }

//   Future<void> saveSession(UserModel user) async {
//     final prefs = await SharedPreferences.getInstance();

//     await prefs.setInt(_userIdKey, user.id ?? 0);
//     await prefs.setString(_roleKey, user.role.toUpperCase());
//   }

//   Future<UserModel?> currentUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     final userId = prefs.getInt(_userIdKey);

//     if (userId == null || userId == 0) {
//       return null;
//     }

//     final data = await db.getUserById(userId);

//     if (data == null) {
//       await logout();
//       return null;
//     }

//     return UserModel.fromMap(data);
//   }

//   Future<String?> currentRole() async {
//     final prefs = await SharedPreferences.getInstance();

//     return prefs.getString(_roleKey);
//   }

//   // Lab yang dikelola admin yang sedang login. Null/kosong untuk role USER.
//   Future<String?> currentAdminLab() async {
//     final user = await currentUser();
//     if (user == null || user.role.toUpperCase() != "ADMIN") {
//       return null;
//     }
//     return user.lab;
//   }

//   Future<bool> hasSession() async {
//     return await currentUser() != null;
//   }

//   Future<UserModel?> updateProfile({
//     required int id,
//     required String name,
//     required String nim,
//     required String phone,
//     required String password,
//     required String role,
//   }) async {
//     await db.updateUser({
//       "id": id,
//       "name": name.trim(),
//       "nim": nim.trim(),
//       "phone": phone.trim(),
//       "password": password,
//       "role": role.toUpperCase(),
//     });

//     final data = await db.getUserById(id);

//     return data == null ? null : UserModel.fromMap(data);
//   }

//   Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();

//     await prefs.remove(_userIdKey);
//     await prefs.remove(_roleKey);
//   }
// }



import '../database/db_helper.dart';
import '../models/users.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userIdKey = "session_user_id";
  static const String _roleKey = "session_role";

  final DBHelper db = DBHelper();

  Future<UserModel?> login(String nim, String password, {String? role}) async {
    final data = await db.login(nim.trim(), password);

    if (data == null) {
      return null;
    }

    final user = UserModel.fromMap(data);

    if (role != null && user.role.toUpperCase() != role.toUpperCase()) {
      return null;
    }

    await saveSession(user);

    return user;
  }

  Future<UserModel> register({
    required String name,
    required String nim,
    required String phone,
    required String password,
  }) async {
    final id = await db.register({
      "name": name.trim(),
      "nim": nim.trim(),
      "phone": phone.trim(),
      "password": password,
      "role": "USER",
      "lab": "",
      "photo": "",
    });

    return UserModel(
      id: id,
      name: name.trim(),
      nim: nim.trim(),
      phone: phone.trim(),
      password: password,
      role: "USER",
      lab: "",
      photo: "",
    );
  }

  Future<void> saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_userIdKey, user.id ?? 0);
    await prefs.setString(_roleKey, user.role.toUpperCase());
  }

  Future<UserModel?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);

    if (userId == null || userId == 0) {
      return null;
    }

    final data = await db.getUserById(userId);

    if (data == null) {
      await logout();
      return null;
    }

    return UserModel.fromMap(data);
  }

  Future<String?> currentRole() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_roleKey);
  }

  // Lab yang dikelola admin yang sedang login. Null/kosong untuk role USER.
  Future<String?> currentAdminLab() async {
    final user = await currentUser();
    if (user == null || user.role.toUpperCase() != "ADMIN") {
      return null;
    }
    return user.lab;
  }

  Future<bool> hasSession() async {
    return await currentUser() != null;
  }

  Future<UserModel?> updateProfile({
    required int id,
    required String name,
    required String nim,
    required String phone,
    required String password,
    required String role,
    String? photo,
  }) async {
    await db.updateUser({
      "id": id,
      "name": name.trim(),
      "nim": nim.trim(),
      "phone": phone.trim(),
      "password": password,
      "role": role.toUpperCase(),
      if (photo != null) "photo": photo,
    });

    final data = await db.getUserById(id);

    return data == null ? null : UserModel.fromMap(data);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_userIdKey);
    await prefs.remove(_roleKey);
  }
}