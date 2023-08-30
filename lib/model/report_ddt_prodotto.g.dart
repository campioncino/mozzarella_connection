// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_ddt_prodotto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDdtProtto _$ReportDdtProttoFromJson(Map<String, dynamic> json) =>
    ReportDdtProtto()
      ..id = json['id'] as int?
      ..sku = json['sku'] as int?
      ..note = json['note'] as String?
      ..price = json['price'] as num?
      ..codice = json['codice'] as String?
      ..listId = json['list_id'] as int?
      ..prodId = json['prod_id'] as int?
      ..orderId = json['order_id'] as int?
      ..quantita = json['quantita'] as int?
      ..imageUrl = json['image_url'] as String?
      ..createdAt = json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String)
      ..dtFinVal = json['dt_fin_val'] == null
          ? null
          : DateTime.parse(json['dt_fin_val'] as String)
      ..descrizione = json['descrizione'] as String?
      ..statoCodice = json['stato_codice'] as String?
      ..denominazione = json['denominazione'] as String?
      ..unimisCodice = json['unimis_codice'] as String?
      ..dtInserimento = json['dt_inserimento'] == null
          ? null
          : DateTime.parse(json['dt_inserimento'] as String)
      ..qtaProduzione = json['qta_produzione'] as int?
      ..tipProdCodice = json['tip_prod_codice'] as String?
      ..unimisProduzione = json['unimis_produzione'] as String?
      ..catProdottoCodice = json['cat_prodotto_codice'] as String?;

Map<String, dynamic> _$ReportDdtProttoToJson(ReportDdtProtto instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('sku', instance.sku);
  writeNotNull('note', instance.note);
  writeNotNull('price', instance.price);
  writeNotNull('codice', instance.codice);
  writeNotNull('list_id', instance.listId);
  writeNotNull('prod_id', instance.prodId);
  writeNotNull('order_id', instance.orderId);
  writeNotNull('quantita', instance.quantita);
  writeNotNull('image_url', instance.imageUrl);
  writeNotNull('created_at', instance.createdAt?.toIso8601String());
  writeNotNull('dt_fin_val', instance.dtFinVal?.toIso8601String());
  writeNotNull('descrizione', instance.descrizione);
  writeNotNull('stato_codice', instance.statoCodice);
  writeNotNull('denominazione', instance.denominazione);
  writeNotNull('unimis_codice', instance.unimisCodice);
  writeNotNull('dt_inserimento', instance.dtInserimento?.toIso8601String());
  writeNotNull('qta_produzione', instance.qtaProduzione);
  writeNotNull('tip_prod_codice', instance.tipProdCodice);
  writeNotNull('unimis_produzione', instance.unimisProduzione);
  writeNotNull('cat_prodotto_codice', instance.catProdottoCodice);
  return val;
}
