import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lab4/db/database_helper.dart';
import 'package:lab4/model/bill.dart';

class BillNotifier extends AsyncNotifier<List<Bill>> {
  @override
  FutureOr<List<Bill>> build() async {
    return await DatabaseHelper.instance.getList();
  }

  Future<void> addObject(Bill object) async {
    await DatabaseHelper.instance.insert(object);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteObject(int id) async {
    await DatabaseHelper.instance.delete(id);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateObject(Bill object) async {
    await DatabaseHelper.instance.update(object);
    ref.invalidateSelf();
    await future;
  }
}

final billNotifierProvider = AsyncNotifierProvider<BillNotifier, List<Bill>>(
  () {
    return BillNotifier();
  },
);
