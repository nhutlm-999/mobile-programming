class Computer {
  final int? id;
  final String productName;
  final int brandId;
  final int categoryId;
  final String cpu;
  final int ram;
  final int storage;
  final double price;
  final int stock;
  final int soldQuantity;
  final bool isFeatured;

  // Các trường lấy từ INNER JOIN với bảng brands và categories
  final String? brandName;
  final String? categoryName;

  Computer({
    this.id,
    required this.productName,
    required this.brandId,
    required this.categoryId,
    required this.cpu,
    required this.ram,
    required this.storage,
    required this.price,
    required this.stock,
    required this.soldQuantity,
    required this.isFeatured,
    this.brandName,
    this.categoryName,
  });

  // Business Calculations (Task 4.5 - tính trực tiếp trong Flutter)
  double get revenue => price * soldQuantity;
  double get inventoryValue => price * stock;
  int get totalUnits => stock + soldQuantity;

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'product_name': productName,
      'brand_id': brandId,
      'category_id': categoryId,
      'cpu': cpu,
      'ram': ram,
      'storage': storage,
      'price': price,
      'stock': stock,
      'sold_quantity': soldQuantity,
      'is_featured': isFeatured
          ? 1
          : 0, // SQLite lưu bool dưới dạng INTEGER 0/1
    };
  }

  factory Computer.fromJson(Map<String, dynamic> json) {
    return Computer(
      id: json['id'] as int?,
      productName: json['product_name'] as String,
      brandId: (json['brand_id'] as num?)?.toInt() ?? 0,
      categoryId: (json['category_id'] as num?)?.toInt() ?? 0,
      cpu: json['cpu'] as String,
      ram: (json['ram'] as num).toInt(),
      storage: (json['storage'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      soldQuantity: (json['sold_quantity'] as num).toInt(),
      isFeatured: (json['is_featured'] as num).toInt() == 1,
      brandName: json['brand_name'] as String?,
      categoryName: json['category_name'] as String?,
    );
  }
}
