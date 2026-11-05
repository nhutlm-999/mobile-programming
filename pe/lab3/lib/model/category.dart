class CategoryModel {
  final int? id;
  final String categoryName;
  final int totalProducts; // Được tính từ SQL LEFT JOIN + COUNT(c.id)

  CategoryModel({this.id, required this.categoryName, this.totalProducts = 0});

  Map<String, dynamic> toJson() {
    return {if (id != null) 'id': id, 'category_name': categoryName};
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int?,
      categoryName: json['category_name'] as String,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
    );
  }
}
