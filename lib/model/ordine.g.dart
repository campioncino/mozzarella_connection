// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ordine _$OrdineFromJson(Map<String, dynamic> json) => Ordine()
  ..errors = (json['errors'] as List<dynamic>?)
      ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..data = json['data'] as List<dynamic>?
  ..success = json['success'] as bool?
  ..status = json['status'] as int?
  ..count = json['count'] as int?
  ..id = json['id'] as int?
  ..utenteId = json['utente_id'] as String?
  ..cartId = json['cart_id'] as int?
  ..pvenditaId = json['pvendita_id'] as int?
  ..statoCodice = json['stato_codice'] as String?
  ..createdAt = json['created_at'] as String?
  ..dtConsegna = AppUtils.stringToDatePostgres(json['data_consegna'] as String?)
  ..indirizzoConsegna = json['indirizzo_consegna'] as String?
  ..note = json['note'] as String?
  ..total = json['total'] as num?
  ..numero = json['numero'] as num?
  ..tipoFiscaleCodice = json['tipo_fiscale_codice'] as String?;

Map<String, dynamic> _$OrdineToJson(Ordine instance) {
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
  writeNotNull('utente_id', instance.utenteId);
  writeNotNull('cart_id', instance.cartId);
  writeNotNull('pvendita_id', instance.pvenditaId);
  writeNotNull('stato_codice', instance.statoCodice);
  writeNotNull('created_at', instance.createdAt);
  writeNotNull('data_consegna', AppUtils.dateToString(instance.dtConsegna));
  writeNotNull('indirizzo_consegna', instance.indirizzoConsegna);
  writeNotNull('note', instance.note);
  writeNotNull('total', instance.total);
  writeNotNull('numero', instance.numero);
  writeNotNull('tipo_fiscale_codice', instance.tipoFiscaleCodice);
  return val;
}
