// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listino.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Listino _$ListinoFromJson(Map<String, dynamic> json) => Listino()
  ..errors = (json['errors'] as List<dynamic>?)
      ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..data = json['data'] as List<dynamic>?
  ..success = json['success'] as bool?
  ..status = json['status'] as int?
  ..count = json['count'] as int?
  ..id = json['id'] as int?
  ..createdAt = json['created_at'] as String?
  ..catId = json['cat_id'] as int?
  ..dtEvento = AppUtils.stringToDate(json['dt_evento'] as String?)
  ..dtFinVal = json['dt_fin_val'] as String?
  ..descrizione = json['descrizione'] as String?
  ..dtIniVal = json['dt_ini_val'] as String?
  ..note = json['note'] as String?
  ..active = json['active'] as bool?;

Map<String, dynamic> _$ListinoToJson(Listino instance) {
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
  writeNotNull('cat_id', instance.catId);
  writeNotNull('dt_evento', AppUtils.dateToString(instance.dtEvento));
  writeNotNull('dt_fin_val', instance.dtFinVal);
  writeNotNull('descrizione', instance.descrizione);
  writeNotNull('dt_ini_val', instance.dtIniVal);
  writeNotNull('note', instance.note);
  writeNotNull('active', instance.active);
  return val;
}
