class Fruit {
  final int id;
  final String name;
  final String origin;
  final double price;
  final String expiredDate;

  Fruit({
    required this.id,
    required this.name,
    required this.origin,
    required this.price,
    required this.expiredDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'origin': origin,
      'price': price,
      'expiredDate': expiredDate,
    };
  }

  factory Fruit.fromMap(Map<String, dynamic> map) {
    return Fruit(
      id: map['id'],
      name: map['name'],
      origin: map['origin'],
      price: map['price'],
      expiredDate: map['expiredDate'],
    );
  }
}
