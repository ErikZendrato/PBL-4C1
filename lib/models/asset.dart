class AssetModel {
  int? id;

  String name;

  String category;

  String lab;

  String description;

  int stock;

  String image;

  String status;

  AssetModel({
    this.id,

    required this.name,

    required this.category,

    required this.lab,

    required this.description,

    required this.stock,

    required this.image,

    this.status = "available",
  });

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map["id"],

      name: map["name"] ?? "",

      category: map["category"] ?? "",

      lab: map["lab"] ?? "",

      description: map["description"] ?? "",

      stock: map["stock"] ?? 0,

      image: map["image"] ?? "",

      status: map["status"] ?? "available",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,

      "name": name,

      "category": category,

      "lab": lab,

      "description": description,

      "stock": stock,

      "image": image,

      "status": status,
    };
  }
}
