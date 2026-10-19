import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab4_15oct/data/datasources/bill_local_datasource.dart';
import 'package:lab4_15oct/data/models/bill.dart';

final billLocalDataSourceProvider = Provider<BillLocalDataSource>((ref) {
  return BillLocalDataSource.instance;
});

final billsProvider = AsyncNotifierProvider<BillsNotifier, List<Bill>>(
  BillsNotifier.new,
);

class BillsNotifier extends AsyncNotifier<List<Bill>> {
  BillLocalDataSource get _billLocalDataSource =>
      ref.read(billLocalDataSourceProvider);

  @override
  Future<List<Bill>> build() async {
    return _billLocalDataSource.getAllBills();
  }

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _billLocalDataSource.getAllBills());
  }

  Future<Bill> addBill(Bill bill) async {
    final saveBill = await _billLocalDataSource.insertBill(bill);
    await reload();
    return saveBill;
  }

  Future<void> updateBill(Bill bill) async {
    await _billLocalDataSource.updateBill(bill);
    await reload();
  }

  Future<void> deleteBill(int id) async {
    await _billLocalDataSource.deleteBill(id);
    await reload();
  }

  Future<Bill?> getById(int id) async {
    return _billLocalDataSource.getBillById(id);
  }
}
