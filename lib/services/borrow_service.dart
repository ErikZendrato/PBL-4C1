// import '../database/db_helper.dart';
// import '../models/asset.dart';
// import '../models/borrow.dart';

// class BorrowService {
//   final DBHelper db = DBHelper();

//   Future<List<AssetModel>> getAssets({String? lab}) async {
//     final rows = await db.getAssets(lab: lab);

//     return rows.map(AssetModel.fromMap).toList();
//   }

//   Future<List<String>> getLabs() async {
//     final assets = await getAssets();
//     final labs = assets.map((asset) => asset.lab).toSet().toList()..sort();

//     return labs;
//   }

//   Future<int> createBorrow({
//     required int userId,
//     required int assetId,
//     required DateTime borrowDate,
//     required DateTime returnDate,
//     required String purpose,
//   }) async {
//     final borrow = BorrowModel(
//       userId: userId,
//       assetId: assetId,
//       borrowDate: _dateKey(borrowDate),
//       returnDate: _dateKey(returnDate),
//       purpose: purpose.trim(),
//     );

//     return await db.borrow(borrow.toMap());
//   }

//   Future<List<Map<String, dynamic>>> getUserBorrows({
//     required int userId,
//     String? status,
//   }) async {
//     return await db.getBorrowDetails(userId: userId, status: status);
//   }

//   Future<List<Map<String, dynamic>>> getAllBorrows({String? status}) async {
//     return await db.getBorrowDetails(status: status);
//   }

//   Future<int> updateStatus(int id, String status) async {
//     return await db.updateBorrowStatus(id, status);
//   }

//   Future<Map<String, int>> getStats() async {
//     return await db.getBorrowStats();
//   }

//   String _dateKey(DateTime value) {
//     return value.toIso8601String().substring(0, 10);
//   }
// }

import '../database/db_helper.dart';
import '../models/asset.dart';
import '../models/borrow.dart';

class BorrowService {
  final DBHelper db = DBHelper();

  Future<List<AssetModel>> getAssets({String? lab}) async {
    final rows = await db.getAssets(lab: lab);

    return rows.map(AssetModel.fromMap).toList();
  }

  Future<List<String>> getLabs() async {
    return DBHelper.labs;
  }

  Future<int> addAsset(AssetModel asset) async {
    return await db.addAsset(asset.toMap()..remove("id"));
  }

  Future<int> updateAsset(AssetModel asset) async {
    return await db.updateAsset(asset.toMap());
  }

  Future<int> deleteAsset(int id) async {
    return await db.deleteAsset(id);
  }

  Future<int> createBorrow({
    required int userId,
    required int assetId,
    required DateTime borrowDate,
    required DateTime returnDate,
    required String purpose,
    String jaminanImage = "",
  }) async {
    final borrow = BorrowModel(
      userId: userId,
      assetId: assetId,
      borrowDate: _dateKey(borrowDate),
      returnDate: _dateKey(returnDate),
      purpose: purpose.trim(),
      jaminanImage: jaminanImage,
    );

    return await db.borrow(borrow.toMap());
  }

  Future<List<Map<String, dynamic>>> getUserBorrows({
    required int userId,
    String? status,
  }) async {
    return await db.getBorrowDetails(userId: userId, status: status);
  }

  // `lab` dipakai admin: hanya lihat peminjaman untuk alat di labnya.
  Future<List<Map<String, dynamic>>> getAllBorrows({
    String? status,
    String? lab,
  }) async {
    return await db.getBorrowDetails(status: status, lab: lab);
  }

  Future<int> updateStatus(int id, String status) async {
    return await db.updateBorrowStatus(id, status);
  }

  Future<Map<String, int>> getStats({String? lab}) async {
    return await db.getBorrowStats(lab: lab);
  }

  String _dateKey(DateTime value) {
    return value.toIso8601String().substring(0, 10);
  }
}