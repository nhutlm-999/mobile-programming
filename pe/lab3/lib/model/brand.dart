class Brand {
  final int? id;
  final String brandName;
  final String country;
  final int foundedYear;
  final int totalProducts; // Được tính từ SQL LEFT JOIN + COUNT(c.id)

  Brand({
    this.id,
    required this.brandName,
    required this.country,
    required this.foundedYear,
    this.totalProducts = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'brand_name': brandName,
      'country': country,
      'founded_year': foundedYear,
    };
  }

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['id'] as int?,
      brandName: json['brand_name'] as String,
      country: json['country'] as String,
      foundedYear: json['founded_year'] as int,
      totalProducts: (json['totalProducts'] as num?)?.toInt() ?? 0,
    );
  }
}
