// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prodotto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Prodotto _$ProdottoFromJson(Map<String, dynamic> json) => Prodotto()
  ..errors = (json['errors'] as List<dynamic>?)
      ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..data = json['data'] as List<dynamic>?
  ..success = json['success'] as bool?
  ..status = json['status'] as int?
  ..count = json['count'] as int?
  ..prodId = json['prod_id'] as int?
  ..codice = json['codice'] as String?
  ..denominazione = json['denominazione'] as String?
  ..descrizione = json['descrizione'] as String?
  ..unimisCodice = json['unimis_codice'] as String?
  ..dtInserimento = json['dt_inserimento'] as String?
  ..dtFinVal = json['dt_fin_val'] as String?
  ..quantita = json['quantita'] as num?
  ..catProdottoCodice = json['cat_prodotto_codice'] as String?;

Map<String, dynamic> _$ProdottoToJson(Prodotto instance) {
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
  writeNotNull('codice', instance.codice);
  writeNotNull('denominazione', instance.denominazione);
  writeNotNull('descrizione', instance.descrizione);
  writeNotNull('unimis_codice', instance.unimisCodice);
  writeNotNull('dt_inserimento', instance.dtInserimento);
  writeNotNull('dt_fin_val', instance.dtFinVal);
  writeNotNull('quantita', instance.quantita);
  writeNotNull('cat_prodotto_codice', instance.catProdottoCodice);
  return val;
}
