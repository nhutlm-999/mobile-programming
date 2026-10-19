// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Bill _$BillFromJson(Map<String, dynamic> json) => _Bill(
  id: (json['id'] as num?)?.toInt(),
  billName: json['billName'] as String,
  category: json['category'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String? ?? 'Unpaid',
  dueDate: json['dueDate'] as String,
);

Map<String, dynamic> _$BillToJson(_Bill instance) => <String, dynamic>{
  'id': instance.id,
  'billName': instance.billName,
  'category': instance.category,
  'amount': instance.amount,
  'status': instance.status,
  'dueDate': instance.dueDate,
};
