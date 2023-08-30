// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

App _$AppFromJson(Map<String, dynamic> json) => App()
  ..id = json['id'] as int?
  ..nome = json['nome'] as String?
  ..packageName = json['packageName'] as String?
  ..descrizione = json['descrizione'] as String?
  ..versione = json['versione'] as String?
  ..visibile = json['visibile'] as String?;

Map<String, dynamic> _$AppToJson(App instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('id', instance.id);
  writeNotNull('nome', instance.nome);
  writeNotNull('packageName', instance.packageName);
  writeNotNull('descrizione', instance.descrizione);
  writeNotNull('versione', instance.versione);
  writeNotNull('visibile', instance.visibile);
  return val;
}
