// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'punto_vendita.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PuntoVendita _$PuntoVenditaFromJson(Map<String, dynamic> json) => PuntoVendita()
  ..errors = (json['errors'] as List<dynamic>?)
      ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..data = json['data'] as List<dynamic>?
  ..success = json['success'] as bool?
  ..status = json['status'] as int?
  ..count = json['count'] as int?
  ..id = json['id'] as int?
  ..createdAt = json['created_at'] as String?
  ..partitaIva = json['partita_iva'] as String?
  ..telefono = json['telefono'] as String?
  ..indirizzo = json['indirizzo'] as String?
  ..dtFinVal = json['dt_fin_val'] as String?
  ..denominazione = json['denominazione'] as String?
  ..idFatturazione = json['id_fatturazione'] as String?
  ..catId = json['cat_id'] as int?
  ..ragSociale = json['rag_sociale'] as String?
  ..indirizzoConsegna = json['indirizzo_consegna'] as String?
  ..capConsegna = json['cap_consegna'] as String?
  ..flFattura = json['fl_fattura'] as bool?
  ..flRicevuta = json['fl_ricevuta'] as bool?;

Map<String, dynamic> _$PuntoVenditaToJson(PuntoVendita instance) {
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
  writeNotNull('partita_iva', instance.partitaIva);
  writeNotNull('telefono', instance.telefono);
  writeNotNull('indirizzo', instance.indirizzo);
  writeNotNull('dt_fin_val', instance.dtFinVal);
  writeNotNull('denominazione', instance.denominazione);
  writeNotNull('id_fatturazione', instance.idFatturazione);
  writeNotNull('cat_id', instance.catId);
  writeNotNull('rag_sociale', instance.ragSociale);
  writeNotNull('indirizzo_consegna', instance.indirizzoConsegna);
  writeNotNull('cap_consegna', instance.capConsegna);
  writeNotNull('fl_fattura', instance.flFattura);
  writeNotNull('fl_ricevuta', instance.flRicevuta);
  return val;
}
