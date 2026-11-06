import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tvinh_fruit_sell/db/database_helper.dart';
import 'package:tvinh_fruit_sell/model/fruit.dart';

class FruitNotifier extends AsyncNotifier<List<Fruit>> {
  @override
  Future<List<Fruit>> build() async {
    final dbHelper = DatabaseHelper.instance;
    return await dbHelper.getList();
  }

  Future<void> addFruit(Fruit fruit) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.insert(fruit);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteFruit(int id) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.delete(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateFruit(Fruit fruit) async {
    final dbHelper = DatabaseHelper.instance;
    await dbHelper.update(fruit);
    ref.invalidateSelf();
    await future;
  }
}

final fruitNotifierProvider = AsyncNotifierProvider<FruitNotifier, List<Fruit>>(
  FruitNotifier.new,
);
