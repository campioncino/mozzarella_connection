// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_item_ext.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CartItemExt _$CartItemExtFromJson(Map<String, dynamic> json) => CartItemExt()
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
  ..note = json['note'] as String?
  ..catId = json['cat_id'] as int?
  ..catDescrizione = json['cat_descrizione'] as String?
  ..listId = json['list_id'] as int?
  ..listDescrizione = json['list_descrizione'] as String?
  ..price = json['price'] as num?
  ..prodCodice = json['prod_codice'] as String?
  ..prodDenominazione = json['prod_denominazione'] as String?
  ..prodDescrizione = json['prod_descrizione'] as String?
  ..prodUnimisCodice = json['prod_unimis_codice'] as String?
  ..prodUnimisDescrizione = json['prod_unimis_descrizione'] as String?;

Map<String, dynamic> _$CartItemExtToJson(CartItemExt instance) {
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
  writeNotNull('cat_id', instance.catId);
  writeNotNull('cat_descrizione', instance.catDescrizione);
  writeNotNull('list_id', instance.listId);
  writeNotNull('list_descrizione', instance.listDescrizione);
  writeNotNull('price', instance.price);
  writeNotNull('prod_codice', instance.prodCodice);
  writeNotNull('prod_denominazione', instance.prodDenominazione);
  writeNotNull('prod_descrizione', instance.prodDescrizione);
  writeNotNull('prod_unimis_codice', instance.prodUnimisCodice);
  writeNotNull('prod_unimis_descrizione', instance.prodUnimisDescrizione);
  return val;
}
