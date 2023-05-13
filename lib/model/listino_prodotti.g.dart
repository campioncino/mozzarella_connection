// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listino_prodotti.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListinoProdotti _$ListinoProdottiFromJson(Map<String, dynamic> json) =>
    ListinoProdotti()
      ..errors = (json['errors'] as List<dynamic>?)
          ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
          .toList()
      ..data = json['data'] as List<dynamic>?
      ..success = json['success'] as bool?
      ..status = json['status'] as int?
      ..count = json['count'] as int?
      ..prodId = json['prod_id'] as int?
      ..listId = json['list_id'] as int?
      ..price = json['price'] as num?
      ..sku = json['sku'] as int?;

Map<String, dynamic> _$ListinoProdottiToJson(ListinoProdotti instance) {
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
  writeNotNull('prod_id', instance.prodId);
  writeNotNull('list_id', instance.listId);
  writeNotNull('price', instance.price);
  writeNotNull('sku', instance.sku);
  return val;
}
