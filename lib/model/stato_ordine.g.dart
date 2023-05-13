// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stato_ordine.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatoOrdine _$StatoOrdineFromJson(Map<String, dynamic> json) => StatoOrdine()
  ..errors = (json['errors'] as List<dynamic>?)
      ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..data = json['data'] as List<dynamic>?
  ..success = json['success'] as bool?
  ..status = json['status'] as int?
  ..count = json['count'] as int?
  ..id = json['id'] as int?
  ..codice = json['codice'] as String?
  ..descrizione = json['descrizione'] as String?;

Map<String, dynamic> _$StatoOrdineToJson(StatoOrdine instance) {
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
  writeNotNull('codice', instance.codice);
  writeNotNull('descrizione', instance.descrizione);
  return val;
}
