import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab3/database/database_helper.dart';
import 'package:lab3/model/brand.dart';

final brandNotifierProvider = AsyncNotifierProvider<BrandNotifier, List<Brand>>(
  () {
    return BrandNotifier();
  },
);

class BrandNotifier extends AsyncNotifier<List<Brand>> {
  String _searchKeyword = '';
  @override
  Future<List<Brand>> build() async {
    return DatabaseHelper.instance.getBrands(keyword: _searchKeyword);
  }

  Future<void> addBrand(Brand brand) async {
    await DatabaseHelper.instance.insertBrand(brand);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateBrand(Brand brand) async {
    await DatabaseHelper.instance.updateBrand(brand);
    ref.invalidateSelf();
    await future;
  }

  Future<bool> deleteBrand(int id) async {
    final usedCount = await DatabaseHelper.instance.countComputersByBrand(id);
    if (usedCount > 0) {
      return false;
    }
    await DatabaseHelper.instance.deleteBrand(id);
    ref.invalidateSelf();
    await future;
    return true;
  }

  Future<void> searchBrands(String keyword) async {
    _searchKeyword = keyword;
    ref.invalidateSelf();
    await future;
  }
}
