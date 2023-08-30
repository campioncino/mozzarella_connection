// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_ddt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDdt _$ReportDdtFromJson(Map<String, dynamic> json) => ReportDdt()
  ..causale = json['causale'] as String?
  ..dataDDT = json['data_ddt'] == null
      ? null
      : DateTime.parse(json['data_ddt'] as String)
  ..ddtInfo = json['ddt_info'] as Map<String, dynamic>?
  ..ddtNumero = json['ddt_numero'] as num?
  ..noteOrdine = json['note_ordine'] as String?
  ..numeroOrdine = json['numero_ordine'] as num?
  ..totaleOrdine = json['totale_ordine'] as num?
  ..costoSpedizione = json['costo_spedizione'] as String?
  ..tipoFatturazione = json['tipo_fatturazione'] as String?
  ..vettoreTrasporto = json['vettore_trasporto'] as String?
  ..indirizzoConsegnaOrdine = json['indirizzo_consegna_ordine'] as String?;

Map<String, dynamic> _$ReportDdtToJson(ReportDdt instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('causale', instance.causale);
  writeNotNull('data_ddt', instance.dataDDT?.toIso8601String());
  writeNotNull('ddt_info', instance.ddtInfo);
  writeNotNull('ddt_numero', instance.ddtNumero);
  writeNotNull('note_ordine', instance.noteOrdine);
  writeNotNull('numero_ordine', instance.numeroOrdine);
  writeNotNull('totale_ordine', instance.totaleOrdine);
  writeNotNull('costo_spedizione', instance.costoSpedizione);
  writeNotNull('tipo_fatturazione', instance.tipoFatturazione);
  writeNotNull('vettore_trasporto', instance.vettoreTrasporto);
  writeNotNull('indirizzo_consegna_ordine', instance.indirizzoConsegnaOrdine);
  return val;
}
