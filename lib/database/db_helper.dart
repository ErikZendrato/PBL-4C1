// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';

// class DBHelper {
//   static const String _databaseName = "labloan.db";
//   static const int _databaseVersion = 7;

//   static const List<String> labs = [
//     "Lab Multimedia",
//     "Lab RPL",
//     "Lab AJK",
//     "Lab ComputerVision",
//   ];

//   static Database? _database;

//   Future<Database> get database async {
//     if (_database != null) {
//       return _database!;
//     }

//     _database = await initDB();

//     return _database!;
//   }

//   Future<Database> initDB() async {
//     String path = join(await getDatabasesPath(), _databaseName);

//     return await openDatabase(
//       path,
//       version: _databaseVersion,
//       onCreate: (db, version) async {
//         await createTables(db);
//       },
//       onUpgrade: (db, oldVersion, newVersion) async {
//         await migrateDB(db, oldVersion, newVersion);
//       },
//     );
//   }

//   Future createTables(Database db) async {
//     await db.execute('''
// CREATE TABLE IF NOT EXISTS users(
// id INTEGER PRIMARY KEY AUTOINCREMENT,
// name TEXT NOT NULL,
// nim TEXT NOT NULL UNIQUE,
// phone TEXT NOT NULL DEFAULT '',
// password TEXT NOT NULL,
// role TEXT NOT NULL DEFAULT 'USER',
// lab TEXT NOT NULL DEFAULT '',
// photo TEXT NOT NULL DEFAULT ''
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS assets(
// id INTEGER PRIMARY KEY AUTOINCREMENT,
// name TEXT NOT NULL,
// category TEXT NOT NULL,
// lab TEXT NOT NULL,
// description TEXT NOT NULL,
// stock INTEGER NOT NULL DEFAULT 0,
// image TEXT NOT NULL DEFAULT '',
// status TEXT NOT NULL DEFAULT 'available'
// )
// ''');

//     await db.execute('''
// CREATE TABLE IF NOT EXISTS borrow(
// id INTEGER PRIMARY KEY AUTOINCREMENT,
// userId INTEGER NOT NULL,
// assetId INTEGER NOT NULL,
// borrowDate TEXT NOT NULL,
// returnDate TEXT NOT NULL,
// purpose TEXT NOT NULL,
// status TEXT NOT NULL DEFAULT 'Menunggu',
// jaminanImage TEXT NOT NULL DEFAULT '',
// FOREIGN KEY(userId) REFERENCES users(id),
// FOREIGN KEY(assetId) REFERENCES assets(id)
// )
// ''');

//     await createIndexes(db);
//     await seedAdmins(db);
//   }

//   Future migrateDB(Database db, int oldVersion, int newVersion) async {
//     if (oldVersion < 2) {
//       await ensureTable(db, "users", '''
// CREATE TABLE IF NOT EXISTS users(
// id INTEGER PRIMARY KEY AUTOINCREMENT,
// name TEXT NOT NULL,
// nim TEXT NOT NULL UNIQUE,
// phone TEXT NOT NULL DEFAULT '',
// password TEXT NOT NULL,
// role TEXT NOT NULL DEFAULT 'USER'
// )
// ''');

//       await ensureTable(db, "assets", '''
// CREATE TABLE IF NOT EXISTS assets(
// id INTEGER PRIMARY KEY AUTOINCREMENT,
// name TEXT NOT NULL,
// category TEXT NOT NULL,
// lab TEXT NOT NULL,
// description TEXT NOT NULL,
// stock INTEGER NOT NULL DEFAULT 0,
// image TEXT NOT NULL DEFAULT '',
// status TEXT NOT NULL DEFAULT 'available'
// )
// ''');

//       await ensureTable(db, "borrow", '''
// CREATE TABLE IF NOT EXISTS borrow(
// id INTEGER PRIMARY KEY AUTOINCREMENT,
// userId INTEGER NOT NULL,
// assetId INTEGER NOT NULL,
// borrowDate TEXT NOT NULL,
// returnDate TEXT NOT NULL,
// purpose TEXT NOT NULL,
// status TEXT NOT NULL DEFAULT 'Menunggu'
// )
// ''');

//       await addColumnIfMissing(db, "users", "nim", "TEXT");
//       await addColumnIfMissing(db, "users", "phone", "TEXT NOT NULL DEFAULT ''");
//       await addColumnIfMissing(db, "assets", "status", "TEXT NOT NULL DEFAULT 'available'");

//       await db.execute('''
// UPDATE users
// SET nim = CASE
//   WHEN LOWER(role) = 'admin' THEN 'admin'
//   WHEN nim IS NULL OR nim = '' THEN COALESCE(email, 'user_' || id)
//   ELSE nim
// END
// ''');

//       await db.execute("UPDATE users SET phone = '' WHERE phone IS NULL");
//       await db.execute("UPDATE users SET role = UPPER(role) WHERE role IS NOT NULL");
//       await db.execute("UPDATE assets SET status = 'available' WHERE status IS NULL OR status = ''");
//       await db.execute("UPDATE borrow SET status = 'Menunggu' WHERE status IS NULL OR status = ''");
//     }

//     if (oldVersion < 3) {
//       await addColumnIfMissing(db, "users", "lab", "TEXT NOT NULL DEFAULT ''");

//       await db.execute('''
// UPDATE users SET lab = ?
// WHERE LOWER(role) = 'admin' AND (lab IS NULL OR lab = '')
// ''', [labs.first]);
//     }

//     if (oldVersion < 4) {
//       await db.delete("assets");
//     }

//     if (oldVersion < 5) {
//       await addColumnIfMissing(db, "users", "photo", "TEXT NOT NULL DEFAULT ''");
//     }

//     if (oldVersion < 6) {
//       await _renameLab(db, oldName: "Lab Jaringan", newName: "Lab AJK");
//       await _renameLab(db, oldName: "Lab Informatika", newName: "Lab ComputerVision");
//     }

//     if (oldVersion < 7) {
//       await addColumnIfMissing(db, "borrow", "jaminanImage", "TEXT NOT NULL DEFAULT ''");
//     }

//     await createIndexes(db);
//     await seedAdmins(db);
//   }

//   Future _renameLab(Database db, {required String oldName, required String newName}) async {
//     await db.rawUpdate(
//       "UPDATE assets SET lab = ? WHERE lab = ?",
//       [newName, oldName],
//     );

//     final oldUsername = "admin_${_slug(oldName)}";
//     final newUsername = "admin_${_slug(newName)}";

//     await db.rawUpdate(
//       "UPDATE users SET lab = ?, nim = ? WHERE lab = ? AND nim = ?",
//       [newName, newUsername, oldName, oldUsername],
//     );
//   }

//   Future ensureTable(Database db, String table, String sql) async {
//     final result = await db.rawQuery(
//       "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
//       [table],
//     );

//     if (result.isEmpty) {
//       await db.execute(sql);
//     }
//   }

//   Future<bool> columnExists(Database db, String table, String column) async {
//     final columns = await db.rawQuery("PRAGMA table_info($table)");
//     return columns.any((item) => item["name"] == column);
//   }

//   Future addColumnIfMissing(
//     Database db,
//     String table,
//     String column,
//     String definition,
//   ) async {
//     if (!await columnExists(db, table, column)) {
//       await db.execute("ALTER TABLE $table ADD COLUMN $column $definition");
//     }
//   }

//   Future createIndexes(Database db) async {
//     await db.execute('''
// CREATE UNIQUE INDEX IF NOT EXISTS idx_users_nim
// ON users(nim)
// WHERE nim IS NOT NULL AND nim <> ''
// ''');

//     await db.execute('''
// CREATE INDEX IF NOT EXISTS idx_assets_lab
// ON assets(lab)
// ''');

//     await db.execute('''
// CREATE INDEX IF NOT EXISTS idx_borrow_user_status
// ON borrow(userId, status)
// ''');

//     await db.execute('''
// CREATE INDEX IF NOT EXISTS idx_users_lab
// ON users(lab)
// ''');
//   }

//   Future seedAdmins(Database db) async {
//     for (final lab in labs) {
//       final username = "admin_${_slug(lab)}";

//       final existing = await db.query(
//         "users",
//         where: "nim = ?",
//         whereArgs: [username],
//         limit: 1,
//       );

//       if (existing.isEmpty) {
//         await db.insert("users", {
//           "name": "Admin $lab",
//           "nim": username,
//           "phone": "0000000000",
//           "password": "admin123",
//           "role": "ADMIN",
//           "lab": lab,
//           "photo": "",
//         });
//       } else {
//         await db.update(
//           "users",
//           {
//             "name": "Admin $lab",
//             "phone": existing.first["phone"] ?? "0000000000",
//             "password": existing.first["password"] ?? "admin123",
//             "role": "ADMIN",
//             "lab": lab,
//           },
//           where: "id = ?",
//           whereArgs: [existing.first["id"]],
//         );
//       }
//     }
//   }

//   String _slug(String lab) {
//     return lab
//         .toLowerCase()
//         .replaceFirst("lab ", "")
//         .replaceAll(RegExp(r'\s+'), '_');
//   }

//   Future<int> register(Map<String, dynamic> user) async {
//     final db = await database;

//     final data = Map<String, dynamic>.from(user);

//     data["role"] = (data["role"] ?? "USER").toString().toUpperCase();
//     data["phone"] = data["phone"] ?? "";
//     data["lab"] = data["lab"] ?? "";
//     data["photo"] = data["photo"] ?? "";

//     return await db.insert("users", data);
//   }

//   Future<Map<String, dynamic>?> getUserById(int id) async {
//     final db = await database;

//     final result = await db.query(
//       "users",
//       where: "id=?",
//       whereArgs: [id],
//       limit: 1,
//     );

//     if (result.isEmpty) {
//       return null;
//     }

//     return result.first;
//   }

//   Future<Map<String, dynamic>?> login(String nim, String password) async {
//     final db = await database;

//     List<Map<String, dynamic>> result = await db.query(
//       "users",
//       where: "nim=? AND password=?",
//       whereArgs: [nim, password],
//     );

//     if (result.isNotEmpty) {
//       return result.first;
//     }

//     return null;
//   }

//   Future<int> updateUser(Map<String, dynamic> data) async {
//     final db = await database;
//     final user = Map<String, dynamic>.from(data)..remove("passwordConfirm");

//     return await db.update(
//       "users",
//       user,
//       where: "id=?",
//       whereArgs: [user["id"]],
//     );
//   }

//   Future<List<Map<String, dynamic>>> getAssets({String? lab}) async {
//     final db = await database;

//     if (lab == null || lab.isEmpty) {
//       return await db.query("assets", orderBy: "lab ASC, name ASC");
//     }

//     return await db.query(
//       "assets",
//       where: "lab = ?",
//       whereArgs: [lab],
//       orderBy: "name ASC",
//     );
//   }

//   Future<int> addAsset(Map<String, dynamic> data) async {
//     final db = await database;

//     final asset = Map<String, dynamic>.from(data);

//     asset["status"] = asset["status"] ?? "available";

//     return await db.insert("assets", asset);
//   }

//   Future<int> updateAsset(Map<String, dynamic> data) async {
//     final db = await database;

//     return await db.update(
//       "assets",
//       data,
//       where: "id=?",
//       whereArgs: [data["id"]],
//     );
//   }

//   Future<int> deleteAsset(int id) async {
//     final db = await database;

//     return await db.delete("assets", where: "id=?", whereArgs: [id]);
//   }

//   Future<int> borrow(Map<String, dynamic> data) async {
//     final db = await database;

//     final borrow = Map<String, dynamic>.from(data);

//     borrow["status"] = borrow["status"] ?? "Menunggu";
//     borrow["jaminanImage"] = borrow["jaminanImage"] ?? "";

//     return await db.insert("borrow", borrow);
//   }

//   Future<List<Map<String, dynamic>>> getBorrow({
//     int? userId,
//     String? status,
//   }) async {
//     final db = await database;

//     final where = <String>[];
//     final whereArgs = <Object?>[];

//     if (userId != null) {
//       where.add("userId = ?");
//       whereArgs.add(userId);
//     }

//     if (status != null && status.isNotEmpty) {
//       where.add("status = ?");
//       whereArgs.add(status);
//     }

//     return await db.query(
//       "borrow",
//       where: where.isEmpty ? null : where.join(" AND "),
//       whereArgs: whereArgs.isEmpty ? null : whereArgs,
//       orderBy: "id DESC",
//     );
//   }

//   Future<int> updateBorrowStatus(int id, String status) async {
//     final db = await database;

//     return await db.transaction((txn) async {
//       final borrow = await txn.query(
//         "borrow",
//         where: "id=?",
//         whereArgs: [id],
//         limit: 1,
//       );

//       if (borrow.isEmpty) {
//         return 0;
//       }

//       final current = borrow.first;
//       final currentStatus = current["status"]?.toString() ?? "";
//       final assetId = current["assetId"] as int;

//       if (status == "Dipinjam" && currentStatus != "Dipinjam") {
//         final asset = await txn.query(
//           "assets",
//           columns: ["stock"],
//           where: "id=?",
//           whereArgs: [assetId],
//           limit: 1,
//         );

//         final stock = asset.isEmpty ? 0 : asset.first["stock"] as int;

//         if (stock <= 0) {
//           return 0;
//         }

//         await txn.rawUpdate(
//           "UPDATE assets SET stock = stock - 1 WHERE id = ?",
//           [assetId],
//         );
//       }

//       if (currentStatus == "Dipinjam" &&
//           (status == "Selesai" || status == "Ditolak")) {
//         await txn.rawUpdate(
//           "UPDATE assets SET stock = stock + 1 WHERE id = ?",
//           [assetId],
//         );
//       }

//       return await txn.update(
//         "borrow",
//         {"status": status},
//         where: "id=?",
//         whereArgs: [id],
//       );
//     });
//   }

//   Future<List<Map<String, dynamic>>> getBorrowDetails({
//     int? userId,
//     String? status,
//     String? lab,
//   }) async {
//     final db = await database;
//     final where = <String>[];
//     final args = <Object?>[];

//     if (userId != null) {
//       where.add("b.userId = ?");
//       args.add(userId);
//     }

//     if (status != null && status.isNotEmpty) {
//       where.add("b.status = ?");
//       args.add(status);
//     }

//     if (lab != null && lab.isNotEmpty) {
//       where.add("a.lab = ?");
//       args.add(lab);
//     }

//     final whereSql = where.isEmpty ? "" : "WHERE ${where.join(" AND ")}";

//     return await db.rawQuery('''
// SELECT
//   b.id,
//   b.userId,
//   b.assetId,
//   b.borrowDate,
//   b.returnDate,
//   b.purpose,
//   b.status,
//   b.jaminanImage AS jaminanImage,
//   u.name AS userName,
//   u.nim AS userNim,
//   u.phone AS userPhone,
//   a.name AS assetName,
//   a.category AS assetCategory,
//   a.lab AS assetLab,
//   a.image AS assetImage,
//   a.stock AS assetStock,
//   a.description AS assetDescription
// FROM borrow b
// INNER JOIN users u ON u.id = b.userId
// INNER JOIN assets a ON a.id = b.assetId
// $whereSql
// ORDER BY b.id DESC
// ''', args);
//   }

//   // Tanggal pengembalian terdekat dari peminjaman yang masih berstatus "Dipinjam"
//   // untuk alat tsb. Null kalau tidak ada yang sedang dipinjam.
//   Future<String?> getNearestReturnDate(int assetId) async {
//     final db = await database;

//     final result = await db.query(
//       "borrow",
//       columns: ["returnDate"],
//       where: "assetId = ? AND status = ?",
//       whereArgs: [assetId, "Dipinjam"],
//       orderBy: "returnDate ASC",
//       limit: 1,
//     );

//     if (result.isEmpty) {
//       return null;
//     }

//     return result.first["returnDate"] as String?;
//   }

//   // ===== REPORT =====

//   // Ringkasan jumlah peminjaman per status, dalam rentang tanggal (berdasarkan borrowDate).
//   Future<Map<String, int>> getReportSummary({
//     String? lab,
//     required String startDate,
//     required String endDate,
//   }) async {
//     final db = await database;
//     final hasLab = lab != null && lab.isNotEmpty;
//     final labWhere = hasLab ? "AND a.lab = ?" : "";

//     final args = <Object?>[startDate, endDate];
//     if (hasLab) {
//       args.add(lab);
//     }

//     final rows = await db.rawQuery('''
// SELECT b.status AS status, COUNT(*) AS total
// FROM borrow b
// INNER JOIN assets a ON a.id = b.assetId
// WHERE b.borrowDate BETWEEN ? AND ?
// $labWhere
// GROUP BY b.status
// ''', args);

//     final result = <String, int>{
//       "Menunggu": 0,
//       "Dipinjam": 0,
//       "Selesai": 0,
//       "Ditolak": 0,
//     };

//     for (final row in rows) {
//       final status = row["status"]?.toString() ?? "";
//       final total = row["total"] as int? ?? 0;

//       if (result.containsKey(status)) {
//         result[status] = total;
//       }
//     }

//     return result;
//   }

//   // Alat yang paling banyak diajukan/dipinjam dalam rentang tanggal, urut terbanyak.
//   Future<List<Map<String, dynamic>>> getTopBorrowedAssets({
//     String? lab,
//     required String startDate,
//     required String endDate,
//     int limit = 5,
//   }) async {
//     final db = await database;
//     final hasLab = lab != null && lab.isNotEmpty;
//     final labWhere = hasLab ? "AND a.lab = ?" : "";

//     final args = <Object?>[startDate, endDate];
//     if (hasLab) {
//       args.add(lab);
//     }
//     args.add(limit);

//     return await db.rawQuery('''
// SELECT
//   a.id AS assetId,
//   a.name AS assetName,
//   a.image AS assetImage,
//   COUNT(*) AS total
// FROM borrow b
// INNER JOIN assets a ON a.id = b.assetId
// WHERE b.borrowDate BETWEEN ? AND ?
// $labWhere
// GROUP BY b.assetId
// ORDER BY total DESC
// LIMIT ?
// ''', args);
//   }

//   Future<Map<String, int>> getBorrowStats({String? lab}) async {
//     final db = await database;

//     final assetWhere = (lab != null && lab.isNotEmpty) ? "WHERE lab = ?" : "";
//     final assetArgs = (lab != null && lab.isNotEmpty) ? [lab] : <Object?>[];

//     final borrowJoinWhere = (lab != null && lab.isNotEmpty)
//         ? "INNER JOIN assets a ON a.id = b.assetId WHERE a.lab = ? AND b.status = ?"
//         : "WHERE b.status = ?";

//     final assetCount =
//         Sqflite.firstIntValue(
//           await db.rawQuery("SELECT COUNT(*) FROM assets $assetWhere", assetArgs),
//         ) ??
//         0;

//     final activeCount =
//         Sqflite.firstIntValue(
//           await db.rawQuery(
//             "SELECT COUNT(*) FROM borrow b $borrowJoinWhere",
//             (lab != null && lab.isNotEmpty) ? [lab, "Dipinjam"] : ["Dipinjam"],
//           ),
//         ) ??
//         0;

//     final pendingCount =
//         Sqflite.firstIntValue(
//           await db.rawQuery(
//             "SELECT COUNT(*) FROM borrow b $borrowJoinWhere",
//             (lab != null && lab.isNotEmpty) ? [lab, "Menunggu"] : ["Menunggu"],
//           ),
//         ) ??
//         0;

//     final dueTodayWhere = (lab != null && lab.isNotEmpty)
//         ? "INNER JOIN assets a ON a.id = b.assetId WHERE a.lab = ? AND b.status = ? AND b.returnDate = ?"
//         : "WHERE b.status = ? AND b.returnDate = ?";

//     final dueTodayArgs = (lab != null && lab.isNotEmpty)
//         ? [lab, "Dipinjam", DateTime.now().toIso8601String().substring(0, 10)]
//         : ["Dipinjam", DateTime.now().toIso8601String().substring(0, 10)];

//     final dueToday =
//         Sqflite.firstIntValue(
//           await db.rawQuery("SELECT COUNT(*) FROM borrow b $dueTodayWhere", dueTodayArgs),
//         ) ??
//         0;

//     return {
//       "totalAssets": assetCount,
//       "activeBorrows": activeCount,
//       "pendingBorrows": pendingCount,
//       "dueToday": dueToday,
//     };
//   }
// }


import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String _databaseName = "labloan.db";
  static const int _databaseVersion = 8;

  static const List<String> labs = [
    "Lab Multimedia",
    "Lab RPL",
    "Lab AJK",
    "Lab ComputerVision",
  ];

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await initDB();

    return _database!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await migrateDB(db, oldVersion, newVersion);
      },
    );
  }

  Future createTables(Database db) async {
    await db.execute('''
CREATE TABLE IF NOT EXISTS users(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
nim TEXT NOT NULL UNIQUE,
phone TEXT NOT NULL DEFAULT '',
password TEXT NOT NULL,
role TEXT NOT NULL DEFAULT 'USER',
lab TEXT NOT NULL DEFAULT '',
photo TEXT NOT NULL DEFAULT ''
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS assets(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
category TEXT NOT NULL,
lab TEXT NOT NULL,
description TEXT NOT NULL,
stock INTEGER NOT NULL DEFAULT 0,
image TEXT NOT NULL DEFAULT '',
status TEXT NOT NULL DEFAULT 'available'
)
''');

    await db.execute('''
CREATE TABLE IF NOT EXISTS borrow(
id INTEGER PRIMARY KEY AUTOINCREMENT,
userId INTEGER NOT NULL,
assetId INTEGER NOT NULL,
borrowDate TEXT NOT NULL,
returnDate TEXT NOT NULL,
purpose TEXT NOT NULL,
status TEXT NOT NULL DEFAULT 'Menunggu',
jaminanImage TEXT NOT NULL DEFAULT '',
quantity INTEGER NOT NULL DEFAULT 1,
FOREIGN KEY(userId) REFERENCES users(id),
FOREIGN KEY(assetId) REFERENCES assets(id)
)
''');

    await createIndexes(db);
    await seedAdmins(db);
  }

  Future migrateDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await ensureTable(db, "users", '''
CREATE TABLE IF NOT EXISTS users(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
nim TEXT NOT NULL UNIQUE,
phone TEXT NOT NULL DEFAULT '',
password TEXT NOT NULL,
role TEXT NOT NULL DEFAULT 'USER'
)
''');

      await ensureTable(db, "assets", '''
CREATE TABLE IF NOT EXISTS assets(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
category TEXT NOT NULL,
lab TEXT NOT NULL,
description TEXT NOT NULL,
stock INTEGER NOT NULL DEFAULT 0,
image TEXT NOT NULL DEFAULT '',
status TEXT NOT NULL DEFAULT 'available'
)
''');

      await ensureTable(db, "borrow", '''
CREATE TABLE IF NOT EXISTS borrow(
id INTEGER PRIMARY KEY AUTOINCREMENT,
userId INTEGER NOT NULL,
assetId INTEGER NOT NULL,
borrowDate TEXT NOT NULL,
returnDate TEXT NOT NULL,
purpose TEXT NOT NULL,
status TEXT NOT NULL DEFAULT 'Menunggu'
)
''');

      await addColumnIfMissing(db, "users", "nim", "TEXT");
      await addColumnIfMissing(db, "users", "phone", "TEXT NOT NULL DEFAULT ''");
      await addColumnIfMissing(db, "assets", "status", "TEXT NOT NULL DEFAULT 'available'");

      await db.execute('''
UPDATE users
SET nim = CASE
  WHEN LOWER(role) = 'admin' THEN 'admin'
  WHEN nim IS NULL OR nim = '' THEN COALESCE(email, 'user_' || id)
  ELSE nim
END
''');

      await db.execute("UPDATE users SET phone = '' WHERE phone IS NULL");
      await db.execute("UPDATE users SET role = UPPER(role) WHERE role IS NOT NULL");
      await db.execute("UPDATE assets SET status = 'available' WHERE status IS NULL OR status = ''");
      await db.execute("UPDATE borrow SET status = 'Menunggu' WHERE status IS NULL OR status = ''");
    }

    if (oldVersion < 3) {
      await addColumnIfMissing(db, "users", "lab", "TEXT NOT NULL DEFAULT ''");

      await db.execute('''
UPDATE users SET lab = ?
WHERE LOWER(role) = 'admin' AND (lab IS NULL OR lab = '')
''', [labs.first]);
    }

    if (oldVersion < 4) {
      await db.delete("assets");
    }

    if (oldVersion < 5) {
      await addColumnIfMissing(db, "users", "photo", "TEXT NOT NULL DEFAULT ''");
    }

    if (oldVersion < 6) {
      await _renameLab(db, oldName: "Lab Jaringan", newName: "Lab AJK");
      await _renameLab(db, oldName: "Lab Informatika", newName: "Lab ComputerVision");
    }

    if (oldVersion < 7) {
      await addColumnIfMissing(db, "borrow", "jaminanImage", "TEXT NOT NULL DEFAULT ''");
    }

    if (oldVersion < 8) {
      await addColumnIfMissing(db, "borrow", "quantity", "INTEGER NOT NULL DEFAULT 1");
    }

    await createIndexes(db);
    await seedAdmins(db);
  }

  Future _renameLab(Database db, {required String oldName, required String newName}) async {
    await db.rawUpdate(
      "UPDATE assets SET lab = ? WHERE lab = ?",
      [newName, oldName],
    );

    final oldUsername = "admin_${_slug(oldName)}";
    final newUsername = "admin_${_slug(newName)}";

    await db.rawUpdate(
      "UPDATE users SET lab = ?, nim = ? WHERE lab = ? AND nim = ?",
      [newName, newUsername, oldName, oldUsername],
    );
  }

  Future ensureTable(Database db, String table, String sql) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
      [table],
    );

    if (result.isEmpty) {
      await db.execute(sql);
    }
  }

  Future<bool> columnExists(Database db, String table, String column) async {
    final columns = await db.rawQuery("PRAGMA table_info($table)");
    return columns.any((item) => item["name"] == column);
  }

  Future addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    if (!await columnExists(db, table, column)) {
      await db.execute("ALTER TABLE $table ADD COLUMN $column $definition");
    }
  }

  Future createIndexes(Database db) async {
    await db.execute('''
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_nim
ON users(nim)
WHERE nim IS NOT NULL AND nim <> ''
''');

    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_assets_lab
ON assets(lab)
''');

    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_borrow_user_status
ON borrow(userId, status)
''');

    await db.execute('''
CREATE INDEX IF NOT EXISTS idx_users_lab
ON users(lab)
''');
  }

  Future seedAdmins(Database db) async {
    for (final lab in labs) {
      final username = "admin_${_slug(lab)}";

      final existing = await db.query(
        "users",
        where: "nim = ?",
        whereArgs: [username],
        limit: 1,
      );

      if (existing.isEmpty) {
        await db.insert("users", {
          "name": "Admin $lab",
          "nim": username,
          "phone": "0000000000",
          "password": "admin123",
          "role": "ADMIN",
          "lab": lab,
          "photo": "",
        });
      } else {
        await db.update(
          "users",
          {
            "name": "Admin $lab",
            "phone": existing.first["phone"] ?? "0000000000",
            "password": existing.first["password"] ?? "admin123",
            "role": "ADMIN",
            "lab": lab,
          },
          where: "id = ?",
          whereArgs: [existing.first["id"]],
        );
      }
    }
  }

  String _slug(String lab) {
    return lab
        .toLowerCase()
        .replaceFirst("lab ", "")
        .replaceAll(RegExp(r'\s+'), '_');
  }

  Future<int> register(Map<String, dynamic> user) async {
    final db = await database;

    final data = Map<String, dynamic>.from(user);

    data["role"] = (data["role"] ?? "USER").toString().toUpperCase();
    data["phone"] = data["phone"] ?? "";
    data["lab"] = data["lab"] ?? "";
    data["photo"] = data["photo"] ?? "";

    return await db.insert("users", data);
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;

    final result = await db.query(
      "users",
      where: "id=?",
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<Map<String, dynamic>?> login(String nim, String password) async {
    final db = await database;

    List<Map<String, dynamic>> result = await db.query(
      "users",
      where: "nim=? AND password=?",
      whereArgs: [nim, password],
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }

  Future<int> updateUser(Map<String, dynamic> data) async {
    final db = await database;
    final user = Map<String, dynamic>.from(data)..remove("passwordConfirm");

    return await db.update(
      "users",
      user,
      where: "id=?",
      whereArgs: [user["id"]],
    );
  }

  Future<List<Map<String, dynamic>>> getAssets({String? lab}) async {
    final db = await database;

    if (lab == null || lab.isEmpty) {
      return await db.query("assets", orderBy: "lab ASC, name ASC");
    }

    return await db.query(
      "assets",
      where: "lab = ?",
      whereArgs: [lab],
      orderBy: "name ASC",
    );
  }

  Future<int> addAsset(Map<String, dynamic> data) async {
    final db = await database;

    final asset = Map<String, dynamic>.from(data);

    asset["status"] = asset["status"] ?? "available";

    return await db.insert("assets", asset);
  }

  Future<int> updateAsset(Map<String, dynamic> data) async {
    final db = await database;

    return await db.update(
      "assets",
      data,
      where: "id=?",
      whereArgs: [data["id"]],
    );
  }

  Future<int> deleteAsset(int id) async {
    final db = await database;

    return await db.delete("assets", where: "id=?", whereArgs: [id]);
  }

  Future<int> borrow(Map<String, dynamic> data) async {
    final db = await database;

    final borrow = Map<String, dynamic>.from(data);

    borrow["status"] = borrow["status"] ?? "Menunggu";
    borrow["jaminanImage"] = borrow["jaminanImage"] ?? "";
    borrow["quantity"] = borrow["quantity"] ?? 1;

    return await db.insert("borrow", borrow);
  }

  Future<List<Map<String, dynamic>>> getBorrow({
    int? userId,
    String? status,
  }) async {
    final db = await database;

    final where = <String>[];
    final whereArgs = <Object?>[];

    if (userId != null) {
      where.add("userId = ?");
      whereArgs.add(userId);
    }

    if (status != null && status.isNotEmpty) {
      where.add("status = ?");
      whereArgs.add(status);
    }

    return await db.query(
      "borrow",
      where: where.isEmpty ? null : where.join(" AND "),
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: "id DESC",
    );
  }

  Future<int> updateBorrowStatus(int id, String status) async {
    final db = await database;

    return await db.transaction((txn) async {
      final borrow = await txn.query(
        "borrow",
        where: "id=?",
        whereArgs: [id],
        limit: 1,
      );

      if (borrow.isEmpty) {
        return 0;
      }

      final current = borrow.first;
      final currentStatus = current["status"]?.toString() ?? "";
      final assetId = current["assetId"] as int;
      final quantity = (current["quantity"] as int?) ?? 1;

      if (status == "Dipinjam" && currentStatus != "Dipinjam") {
        final asset = await txn.query(
          "assets",
          columns: ["stock"],
          where: "id=?",
          whereArgs: [assetId],
          limit: 1,
        );

        final stock = asset.isEmpty ? 0 : asset.first["stock"] as int;

        if (stock < quantity) {
          return 0;
        }

        await txn.rawUpdate(
          "UPDATE assets SET stock = stock - ? WHERE id = ?",
          [quantity, assetId],
        );
      }

      if (currentStatus == "Dipinjam" &&
          (status == "Selesai" || status == "Ditolak")) {
        await txn.rawUpdate(
          "UPDATE assets SET stock = stock + ? WHERE id = ?",
          [quantity, assetId],
        );
      }

      return await txn.update(
        "borrow",
        {"status": status},
        where: "id=?",
        whereArgs: [id],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getBorrowDetails({
    int? userId,
    String? status,
    String? lab,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];

    if (userId != null) {
      where.add("b.userId = ?");
      args.add(userId);
    }

    if (status != null && status.isNotEmpty) {
      where.add("b.status = ?");
      args.add(status);
    }

    if (lab != null && lab.isNotEmpty) {
      where.add("a.lab = ?");
      args.add(lab);
    }

    final whereSql = where.isEmpty ? "" : "WHERE ${where.join(" AND ")}";

    return await db.rawQuery('''
SELECT
  b.id,
  b.userId,
  b.assetId,
  b.borrowDate,
  b.returnDate,
  b.purpose,
  b.status,
  b.jaminanImage AS jaminanImage,
  b.quantity AS quantity,
  u.name AS userName,
  u.nim AS userNim,
  u.phone AS userPhone,
  a.name AS assetName,
  a.category AS assetCategory,
  a.lab AS assetLab,
  a.image AS assetImage,
  a.stock AS assetStock,
  a.description AS assetDescription
FROM borrow b
INNER JOIN users u ON u.id = b.userId
INNER JOIN assets a ON a.id = b.assetId
$whereSql
ORDER BY b.id DESC
''', args);
  }

  // Tanggal pengembalian terdekat dari peminjaman yang masih berstatus "Dipinjam"
  // untuk alat tsb. Null kalau tidak ada yang sedang dipinjam.
  Future<String?> getNearestReturnDate(int assetId) async {
    final db = await database;

    final result = await db.query(
      "borrow",
      columns: ["returnDate"],
      where: "assetId = ? AND status = ?",
      whereArgs: [assetId, "Dipinjam"],
      orderBy: "returnDate ASC",
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first["returnDate"] as String?;
  }

  // ===== REPORT =====

  // Ringkasan jumlah peminjaman per status, dalam rentang tanggal (berdasarkan borrowDate).
  Future<Map<String, int>> getReportSummary({
    String? lab,
    required String startDate,
    required String endDate,
  }) async {
    final db = await database;
    final hasLab = lab != null && lab.isNotEmpty;
    final labWhere = hasLab ? "AND a.lab = ?" : "";

    final args = <Object?>[startDate, endDate];
    if (hasLab) {
      args.add(lab);
    }

    final rows = await db.rawQuery('''
SELECT b.status AS status, COUNT(*) AS total
FROM borrow b
INNER JOIN assets a ON a.id = b.assetId
WHERE b.borrowDate BETWEEN ? AND ?
$labWhere
GROUP BY b.status
''', args);

    final result = <String, int>{
      "Menunggu": 0,
      "Dipinjam": 0,
      "Selesai": 0,
      "Ditolak": 0,
    };

    for (final row in rows) {
      final status = row["status"]?.toString() ?? "";
      final total = row["total"] as int? ?? 0;

      if (result.containsKey(status)) {
        result[status] = total;
      }
    }

    return result;
  }

  // Alat yang paling banyak diajukan/dipinjam dalam rentang tanggal, urut terbanyak.
  Future<List<Map<String, dynamic>>> getTopBorrowedAssets({
    String? lab,
    required String startDate,
    required String endDate,
    int limit = 5,
  }) async {
    final db = await database;
    final hasLab = lab != null && lab.isNotEmpty;
    final labWhere = hasLab ? "AND a.lab = ?" : "";

    final args = <Object?>[startDate, endDate];
    if (hasLab) {
      args.add(lab);
    }
    args.add(limit);

    return await db.rawQuery('''
SELECT
  a.id AS assetId,
  a.name AS assetName,
  a.image AS assetImage,
  COUNT(*) AS total
FROM borrow b
INNER JOIN assets a ON a.id = b.assetId
WHERE b.borrowDate BETWEEN ? AND ?
$labWhere
GROUP BY b.assetId
ORDER BY total DESC
LIMIT ?
''', args);
  }

  Future<Map<String, int>> getBorrowStats({String? lab}) async {
    final db = await database;

    final assetWhere = (lab != null && lab.isNotEmpty) ? "WHERE lab = ?" : "";
    final assetArgs = (lab != null && lab.isNotEmpty) ? [lab] : <Object?>[];

    final borrowJoinWhere = (lab != null && lab.isNotEmpty)
        ? "INNER JOIN assets a ON a.id = b.assetId WHERE a.lab = ? AND b.status = ?"
        : "WHERE b.status = ?";

    final assetCount =
        Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM assets $assetWhere", assetArgs),
        ) ??
        0;

    final activeCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM borrow b $borrowJoinWhere",
            (lab != null && lab.isNotEmpty) ? [lab, "Dipinjam"] : ["Dipinjam"],
          ),
        ) ??
        0;

    final pendingCount =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM borrow b $borrowJoinWhere",
            (lab != null && lab.isNotEmpty) ? [lab, "Menunggu"] : ["Menunggu"],
          ),
        ) ??
        0;

    final dueTodayWhere = (lab != null && lab.isNotEmpty)
        ? "INNER JOIN assets a ON a.id = b.assetId WHERE a.lab = ? AND b.status = ? AND b.returnDate = ?"
        : "WHERE b.status = ? AND b.returnDate = ?";

    final dueTodayArgs = (lab != null && lab.isNotEmpty)
        ? [lab, "Dipinjam", DateTime.now().toIso8601String().substring(0, 10)]
        : ["Dipinjam", DateTime.now().toIso8601String().substring(0, 10)];

    final dueToday =
        Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM borrow b $dueTodayWhere", dueTodayArgs),
        ) ??
        0;

    return {
      "totalAssets": assetCount,
      "activeBorrows": activeCount,
      "pendingBorrows": pendingCount,
      "dueToday": dueToday,
    };
  }
}