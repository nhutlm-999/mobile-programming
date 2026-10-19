import 'package:freezed_annotation/freezed_annotation.dart';

part 'bill.freezed.dart';
part 'bill.g.dart';

@freezed
abstract class Bill with _$Bill {
  const factory Bill({
    int? id,
    required String billName,
    required String category,
    required double amount,
    @Default('Unpaid') String status,
    required String dueDate,
  }) = _Bill;

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);
}
