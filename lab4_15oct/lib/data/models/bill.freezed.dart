// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bill.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Bill {

 int? get id; String get billName; String get category; double get amount; String get status; String get dueDate;
/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BillCopyWith<Bill> get copyWith => _$BillCopyWithImpl<Bill>(this as Bill, _$identity);

  /// Serializes this Bill to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Bill;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Bill&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.billName, _this.billName) || other.billName == _this.billName)&&(identical(other.category, _this.category) || other.category == _this.category)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.dueDate, _this.dueDate) || other.dueDate == _this.dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Bill;
  return Object.hash(runtimeType,_this.id,_this.billName,_this.category,_this.amount,_this.status,_this.dueDate);
}

@override
String toString() {
  final _this = this as Bill;
  return 'Bill(id: ${_this.id}, billName: ${_this.billName}, category: ${_this.category}, amount: ${_this.amount}, status: ${_this.status}, dueDate: ${_this.dueDate})';
}


}

/// @nodoc
abstract mixin class $BillCopyWith<$Res>  {
  factory $BillCopyWith(Bill value, $Res Function(Bill) _then) = _$BillCopyWithImpl;
@useResult
$Res call({
 int? id, String billName, String category, double amount, String status, String dueDate
});




}
/// @nodoc
class _$BillCopyWithImpl<$Res>
    implements $BillCopyWith<$Res> {
  _$BillCopyWithImpl(this._self, this._then);

  final Bill _self;
  final $Res Function(Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? billName = null,Object? category = null,Object? amount = null,Object? status = null,Object? dueDate = null,}) {
  return _then(Bill(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,billName: null == billName ? _self.billName : billName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Bill].
extension BillPatterns on Bill {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Bill value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Bill value)  $default,){
final _that = this;
switch (_that) {
case _Bill():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Bill value)?  $default,){
final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String billName,  String category,  double amount,  String status,  String dueDate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.billName,_that.category,_that.amount,_that.status,_that.dueDate);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String billName,  String category,  double amount,  String status,  String dueDate)  $default,) {final _that = this;
switch (_that) {
case _Bill():
return $default(_that.id,_that.billName,_that.category,_that.amount,_that.status,_that.dueDate);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String billName,  String category,  double amount,  String status,  String dueDate)?  $default,) {final _that = this;
switch (_that) {
case _Bill() when $default != null:
return $default(_that.id,_that.billName,_that.category,_that.amount,_that.status,_that.dueDate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Bill implements Bill {
  const _Bill({this.id, required this.billName, required this.category, required this.amount, this.status = 'Unpaid', required this.dueDate});
  factory _Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

@override final  int? id;
@override final  String billName;
@override final  String category;
@override final  double amount;
@override@JsonKey() final  String status;
@override final  String dueDate;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BillCopyWith<_Bill> get copyWith => __$BillCopyWithImpl<_Bill>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BillToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Bill&&(identical(other.id, id) || other.id == id)&&(identical(other.billName, billName) || other.billName == billName)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.status, status) || other.status == status)&&(identical(other.dueDate, dueDate) || other.dueDate == dueDate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,billName,category,amount,status,dueDate);
}

@override
String toString() {
    return 'Bill(id: $id, billName: $billName, category: $category, amount: $amount, status: $status, dueDate: $dueDate)';
}


}

/// @nodoc
abstract mixin class _$BillCopyWith<$Res> implements $BillCopyWith<$Res> {
  factory _$BillCopyWith(_Bill value, $Res Function(_Bill) _then) = __$BillCopyWithImpl;
@override @useResult
$Res call({
 int? id, String billName, String category, double amount, String status, String dueDate
});




}
/// @nodoc
class __$BillCopyWithImpl<$Res>
    implements _$BillCopyWith<$Res> {
  __$BillCopyWithImpl(this._self, this._then);

  final _Bill _self;
  final $Res Function(_Bill) _then;

/// Create a copy of Bill
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? billName = null,Object? category = null,Object? amount = null,Object? status = null,Object? dueDate = null,}) {
  return _then(_Bill(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,billName: null == billName ? _self.billName : billName // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,dueDate: null == dueDate ? _self.dueDate : dueDate // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
