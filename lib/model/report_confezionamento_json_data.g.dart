// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_confezionamento_json_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportConfezionamentoJsonData _$ReportConfezionamentoJsonDataFromJson(
        Map<String, dynamic> json) =>
    ReportConfezionamentoJsonData()
      ..prodId = json['prod_id'] as int?
      ..descrizione = json['descrizione'] as String?
      ..denominazione = json['denominazione'] as String?
      ..sumToDeliver = json['sum_to_deliver'] as int?
      ..unimisCodice = json['unimis_codice'] as String?
      ..codice = json['codice'] as String?;

Map<String, dynamic> _$ReportConfezionamentoJsonDataToJson(
    ReportConfezionamentoJsonData instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('prod_id', instance.prodId);
  writeNotNull('descrizione', instance.descrizione);
  writeNotNull('denominazione', instance.denominazione);
  writeNotNull('sum_to_deliver', instance.sumToDeliver);
  writeNotNull('unimis_codice', instance.unimisCodice);
  writeNotNull('codice', instance.codice);
  return val;
}
