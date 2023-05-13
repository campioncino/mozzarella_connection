// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listino_prodotti_ext.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListinoProdottiExt _$ListinoProdottiExtFromJson(Map<String, dynamic> json) =>
    ListinoProdottiExt()
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
      ..sku = json['sku'] as int?
      ..catId = json['cat_id'] as int?
      ..catDescrizione = json['cat_descrizione'] as String?
      ..catDtFinVal = json['cat_dt_fin_val'] as String?
      ..prodCodice = json['prod_codice'] as String?
      ..prodDenominazione = json['prod_denominazione'] as String?
      ..prodDescrzione = json['prod_descrizione'] as String?
      ..prodQuantita = json['prod_quantita'] as int?
      ..prodUnimisCodice = json['prod_unimis_codice'] as String?
      ..prodDtInserimento = json['prod_dt_iniserimento'] as String?
      ..prodDtFinVal = json['prod_dt_fin_val'] as String?
      ..listDescrzione = json['list_descrizione'] as String?
      ..listNote = json['list_note'] as String?
      ..listFinVal = json['list_fin_val'] as String?
      ..listIniVal = json['list_ini_val'] as String?
      ..prodUnimisDescrizione = json['prod_unimis_descrizione'] as String?;

Map<String, dynamic> _$ListinoProdottiExtToJson(ListinoProdottiExt instance) {
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
  writeNotNull('cat_id', instance.catId);
  writeNotNull('cat_descrizione', instance.catDescrizione);
  writeNotNull('cat_dt_fin_val', instance.catDtFinVal);
  writeNotNull('prod_codice', instance.prodCodice);
  writeNotNull('prod_denominazione', instance.prodDenominazione);
  writeNotNull('prod_descrizione', instance.prodDescrzione);
  writeNotNull('prod_quantita', instance.prodQuantita);
  writeNotNull('prod_unimis_codice', instance.prodUnimisCodice);
  writeNotNull('prod_dt_iniserimento', instance.prodDtInserimento);
  writeNotNull('prod_dt_fin_val', instance.prodDtFinVal);
  writeNotNull('list_descrizione', instance.listDescrzione);
  writeNotNull('list_note', instance.listNote);
  writeNotNull('list_fin_val', instance.listFinVal);
  writeNotNull('list_ini_val', instance.listIniVal);
  writeNotNull('prod_unimis_descrizione', instance.prodUnimisDescrizione);
  return val;
}
