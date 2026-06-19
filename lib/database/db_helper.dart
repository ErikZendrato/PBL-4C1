import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static const String _databaseName = "labloan.db";
  static const int _databaseVersion = 2;

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

role TEXT NOT NULL DEFAULT 'USER'

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

FOREIGN KEY(userId) REFERENCES users(id),

FOREIGN KEY(assetId) REFERENCES assets(id)

)

''');

    await createIndexes(db);

    await seedAdmin(db);

    await seedAssets(db);
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
      await addColumnIfMissing(
        db,
        "users",
        "phone",
        "TEXT NOT NULL DEFAULT ''",
      );
      await addColumnIfMissing(
        db,
        "assets",
        "status",
        "TEXT NOT NULL DEFAULT 'available'",
      );

      await db.execute('''
UPDATE users
SET nim = CASE
  WHEN LOWER(role) = 'admin' THEN 'admin'
  WHEN nim IS NULL OR nim = '' THEN COALESCE(email, 'user_' || id)
  ELSE nim
END
''');

      await db.execute("UPDATE users SET phone = '' WHERE phone IS NULL");
      await db.execute(
        "UPDATE users SET role = UPPER(role) WHERE role IS NOT NULL",
      );
      await db.execute(
        "UPDATE assets SET status = 'available' WHERE status IS NULL OR status = ''",
      );
      await db.execute(
        "UPDATE borrow SET status = 'Menunggu' WHERE status IS NULL OR status = ''",
      );
    }

    await createIndexes(db);
    await seedAdmin(db);
    await seedAssets(db);
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
  }

  Future seedAdmin(Database db) async {
    final existing = await db.query(
      "users",
      where: "nim = ? OR LOWER(role) = ?",
      whereArgs: ["admin", "admin"],
      limit: 1,
    );

    final admin = {
      "name": "Admin Lab",

      "nim": "admin",

      "phone": "0000000000",

      "password": "admin123",

      "role": "ADMIN",
    };

    if (existing.isEmpty) {
      await db.insert("users", admin);

      return;
    }

    await db.update(
      "users",
      admin,
      where: "id = ?",
      whereArgs: [existing.first["id"]],
    );
  }

  Future seedAssets(Database db) async {
    List<Map<String, dynamic>> assets = [
      {
        "name": "Kamera DSLR",

        "category": "Kamera",

        "lab": "Lab Multimedia",

        "description":
            "Kamera DSLR untuk dokumentasi praktikum dan proyek multimedia.",

        "stock": 7,

        "image": "camera",

        "status": "available",
      },

      {
        "name": "Tripod kamera",

        "category": "Kamera",

        "lab": "Lab Multimedia",

        "description": "Tripod kamera untuk pengambilan gambar stabil.",

        "stock": 5,

        "image": "tripod",

        "status": "available",
      },

      {
        "name": "Lighting Studio",

        "category": "Lighting",

        "lab": "Lab Multimedia",

        "description": "Lampu studio untuk kebutuhan foto dan video.",

        "stock": 0,

        "image": "lighting",

        "status": "unavailable",
      },

      {
        "name": "Microphone Wireless",

        "category": "Audio",

        "lab": "Lab Multimedia",

        "description":
            "Microphone wireless untuk rekaman audio dan presentasi.",

        "stock": 3,

        "image": "microphone",

        "status": "available",
      },

      {
        "name": "Monitor",

        "category": "Display",

        "lab": "Lab RPL",

        "description":
            "Monitor eksternal untuk praktikum rekayasa perangkat lunak.",

        "stock": 7,

        "image": "monitor",

        "status": "available",
      },

      {
        "name": "Keyboard",

        "category": "Peripheral",

        "lab": "Lab RPL",

        "description":
            "Keyboard praktikum untuk perangkat komputer laboratorium.",

        "stock": 5,

        "image": "keyboard",

        "status": "available",
      },

      {
        "name": "Mouse",

        "category": "Peripheral",

        "lab": "Lab RPL",

        "description": "Mouse komputer cadangan untuk kegiatan praktikum.",

        "stock": 0,

        "image": "mouse",

        "status": "unavailable",
      },

      {
        "name": "Switch",

        "category": "Jaringan",

        "lab": "Lab Jaringan",

        "description":
            "Switch jaringan untuk simulasi dan praktikum jaringan komputer.",

        "stock": 7,

        "image": "switch",

        "status": "available",
      },

      {
        "name": "Wireless adapter",

        "category": "Jaringan",

        "lab": "Lab Jaringan",

        "description": "Wireless adapter untuk pengujian koneksi nirkabel.",

        "stock": 0,

        "image": "wireless_adapter",

        "status": "unavailable",
      },

      {
        "name": "Tang Crimping",

        "category": "Jaringan",

        "lab": "Lab Jaringan",

        "description":
            "Tang crimping untuk pemasangan konektor kabel jaringan.",

        "stock": 5,

        "image": "crimping",

        "status": "available",
      },

      {
        "name": "Harddisk eksternal",

        "category": "Hardware",

        "lab": "Lab Informatika",

        "description": "Harddisk eksternal untuk penyimpanan data praktikum.",

        "stock": 7,

        "image": "harddisk",

        "status": "available",
      },

      {
        "name": "Projector",

        "category": "Display",

        "lab": "Lab Informatika",

        "description":
            "Projector untuk presentasi dan pembelajaran di laboratorium.",

        "stock": 0,

        "image": "projector",

        "status": "unavailable",
      },
    ];

    for (var item in assets) {
      final existing = await db.query(
        "assets",
        where: "name = ? AND lab = ?",
        whereArgs: [item["name"], item["lab"]],
        limit: 1,
      );

      if (existing.isEmpty) {
        await db.insert("assets", item);
      }
    }
  }

  Future<int> register(Map<String, dynamic> user) async {
    final db = await database;

    final data = Map<String, dynamic>.from(user);

    data["role"] = (data["role"] ?? "USER").toString().toUpperCase();
    data["phone"] = data["phone"] ?? "";

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

      if (status == "Dipinjam" && currentStatus != "Dipinjam") {
        final asset = await txn.query(
          "assets",
          columns: ["stock"],
          where: "id=?",
          whereArgs: [assetId],
          limit: 1,
        );

        final stock = asset.isEmpty ? 0 : asset.first["stock"] as int;

        if (stock <= 0) {
          return 0;
        }

        await txn.rawUpdate(
          "UPDATE assets SET stock = stock - 1 WHERE id = ?",
          [assetId],
        );
      }

      if (currentStatus == "Dipinjam" &&
          (status == "Selesai" || status == "Ditolak")) {
        await txn.rawUpdate(
          "UPDATE assets SET stock = stock + 1 WHERE id = ?",
          [assetId],
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

  Future<Map<String, int>> getBorrowStats() async {
    final db = await database;
    final assetCount =
        Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM assets"),
        ) ??
        0;
    final activeCount =
        Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM borrow WHERE status = ?", [
            "Dipinjam",
          ]),
        ) ??
        0;
    final pendingCount =
        Sqflite.firstIntValue(
          await db.rawQuery("SELECT COUNT(*) FROM borrow WHERE status = ?", [
            "Menunggu",
          ]),
        ) ??
        0;
    final dueToday =
        Sqflite.firstIntValue(
          await db.rawQuery(
            "SELECT COUNT(*) FROM borrow WHERE status = ? AND returnDate = ?",
            ["Dipinjam", DateTime.now().toIso8601String().substring(0, 10)],
          ),
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
