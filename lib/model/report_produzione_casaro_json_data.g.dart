// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_produzione_casaro_json_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportProduzioneCasaroJsonData _$ReportProduzioneCasaroJsonDataFromJson(
        Map<String, dynamic> json) =>
    ReportProduzioneCasaroJsonData()
      ..totale = json['totale'] as int?
      ..dettaglio = json['dettaglio'] as String?
      ..tipProdCodice = json['tip_prod_codice'] as String?
      ..unimisProduzione = json['unimis_produzione'] as String?
      ..tipProdDescrizione = json['tip_prod_descrizione'] as String?
      ..qtaProduzione = json['qta_produzione'] as int?;

Map<String, dynamic> _$ReportProduzioneCasaroJsonDataToJson(
    ReportProduzioneCasaroJsonData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('totale', instance.totale);
  writeNotNull('dettaglio', instance.dettaglio);
  writeNotNull('tip_prod_codice', instance.tipProdCodice);
  writeNotNull('unimis_produzione', instance.unimisProduzione);
  writeNotNull('tip_prod_descrizione', instance.tipProdDescrizione);
  writeNotNull('qta_produzione', instance.qtaProduzione);
  return val;
}
