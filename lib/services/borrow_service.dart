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
//     return DBHelper.labs;
//   }

//   Future<int> addAsset(AssetModel asset) async {
//     return await db.addAsset(asset.toMap()..remove("id"));
//   }

//   Future<int> updateAsset(AssetModel asset) async {
//     return await db.updateAsset(asset.toMap());
//   }

//   Future<int> deleteAsset(int id) async {
//     return await db.deleteAsset(id);
//   }

//   Future<int> createBorrow({
//     required int userId,
//     required int assetId,
//     required DateTime borrowDate,
//     required DateTime returnDate,
//     required String purpose,
//     String jaminanImage = "",
//   }) async {
//     final borrow = BorrowModel(
//       userId: userId,
//       assetId: assetId,
//       borrowDate: _dateKey(borrowDate),
//       returnDate: _dateKey(returnDate),
//       purpose: purpose.trim(),
//       jaminanImage: jaminanImage,
//     );

//     return await db.borrow(borrow.toMap());
//   }

//   Future<List<Map<String, dynamic>>> getUserBorrows({
//     required int userId,
//     String? status,
//   }) async {
//     return await db.getBorrowDetails(userId: userId, status: status);
//   }

//   // `lab` dipakai admin: hanya lihat peminjaman untuk alat di labnya.
//   Future<List<Map<String, dynamic>>> getAllBorrows({
//     String? status,
//     String? lab,
//   }) async {
//     return await db.getBorrowDetails(status: status, lab: lab);
//   }

//   Future<int> updateStatus(int id, String status) async {
//     return await db.updateBorrowStatus(id, status);
//   }

//   Future<String?> getNearestReturnDate(int assetId) async {
//     return await db.getNearestReturnDate(assetId);
//   }

//   Future<Map<String, int>> getStats({String? lab}) async {
//     return await db.getBorrowStats(lab: lab);
//   }

//   Future<Map<String, int>> getReportSummary({
//     String? lab,
//     required DateTime start,
//     required DateTime end,
//   }) async {
//     return await db.getReportSummary(
//       lab: lab,
//       startDate: _dateKey(start),
//       endDate: _dateKey(end),
//     );
//   }

//   Future<List<Map<String, dynamic>>> getTopBorrowedAssets({
//     String? lab,
//     required DateTime start,
//     required DateTime end,
//     int limit = 5,
//   }) async {
//     return await db.getTopBorrowedAssets(
//       lab: lab,
//       startDate: _dateKey(start),
//       endDate: _dateKey(end),
//       limit: limit,
//     );
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
    int quantity = 1,
  }) async {
    final borrow = BorrowModel(
      userId: userId,
      assetId: assetId,
      borrowDate: _dateKey(borrowDate),
      returnDate: _dateKey(returnDate),
      purpose: purpose.trim(),
      jaminanImage: jaminanImage,
      quantity: quantity,
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

  Future<String?> getNearestReturnDate(int assetId) async {
    return await db.getNearestReturnDate(assetId);
  }

  Future<Map<String, int>> getStats({String? lab}) async {
    return await db.getBorrowStats(lab: lab);
  }

  Future<Map<String, int>> getReportSummary({
    String? lab,
    required DateTime start,
    required DateTime end,
  }) async {
    return await db.getReportSummary(
      lab: lab,
      startDate: _dateKey(start),
      endDate: _dateKey(end),
    );
  }

  Future<List<Map<String, dynamic>>> getTopBorrowedAssets({
    String? lab,
    required DateTime start,
    required DateTime end,
    int limit = 5,
  }) async {
    return await db.getTopBorrowedAssets(
      lab: lab,
      startDate: _dateKey(start),
      endDate: _dateKey(end),
      limit: limit,
    );
  }

  String _dateKey(DateTime value) {
    return value.toIso8601String().substring(0, 10);
  }
}