class BorrowModel {
  int? id;
  int userId;
  int assetId;
  String borrowDate;
  String returnDate;
  String purpose;
  String status;
  String jaminanImage;
 
  BorrowModel({
    this.id,
    required this.userId,
    required this.assetId,
    required this.borrowDate,
    required this.returnDate,
    required this.purpose,
    this.status = "Menunggu",
    this.jaminanImage = "",
  });
 
  factory BorrowModel.fromMap(Map<String, dynamic> map) {
    return BorrowModel(
      id: map["id"],
      userId: map["userId"] ?? 0,
      assetId: map["assetId"] ?? 0,
      borrowDate: map["borrowDate"] ?? "",
      returnDate: map["returnDate"] ?? "",
      purpose: map["purpose"] ?? "",
      status: map["status"] ?? "Menunggu",
      jaminanImage: map["jaminanImage"] ?? "",
    );
  }
 
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "userId": userId,
      "assetId": assetId,
      "borrowDate": borrowDate,
      "returnDate": returnDate,
      "purpose": purpose,
      "status": status,
      "jaminanImage": jaminanImage,
    };
  }
}
 