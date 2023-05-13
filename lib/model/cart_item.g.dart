// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItem _$CartItemFromJson(Map<String, dynamic> json) => CartItem()
  ..errors = (json['errors'] as List<dynamic>?)
      ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..data = json['data'] as List<dynamic>?
  ..success = json['success'] as bool?
  ..status = json['status'] as int?
  ..count = json['count'] as int?
  ..id = json['id'] as int?
  ..createdAt = json['created_at'] as String?
  ..orderId = json['order_id'] as int?
  ..prodId = json['prod_id'] as int?
  ..statoCodice = json['stato_codice'] as String?
  ..quantita = json['quantita'] as num?
  ..note = json['note'] as String?;

Map<String, dynamic> _$CartItemToJson(CartItem instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('errors', instance.errors?.map((e) => e.toJson()).toList());
  writeNotNull('data', instance.data);
  writeNotNull('success', instance.success);
  writeNotNull('status', instance.status);
  writeNotNull('count', instance.count);
  writeNotNull('id', instance.id);
  writeNotNull('created_at', instance.createdAt);
  writeNotNull('order_id', instance.orderId);
  writeNotNull('prod_id', instance.prodId);
  writeNotNull('stato_codice', instance.statoCodice);
  writeNotNull('quantita', instance.quantita);
  writeNotNull('note', instance.note);
  return val;
}
