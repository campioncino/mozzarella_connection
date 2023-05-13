// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utente.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Utente _$UtenteFromJson(Map<String, dynamic> json) => Utente()
  ..errors = (json['errors'] as List<dynamic>?)
      ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..data = json['data'] as List<dynamic>?
  ..success = json['success'] as bool?
  ..status = json['status'] as int?
  ..count = json['count'] as int?
  ..profileId = json['profile_id'] as String?
  ..username = json['username'] as String?
  ..name = json['name'] as String?
  ..phoneNumber = json['phone_number'] as String?
  ..email = json['email'] as String?
  ..puntoVendita = json['punto_vendita'] as int?
  ..confermato = json['confermato'] as bool?
  ..ruolo = json['ruolo'] as String?
  ..dtFineValidita = json['dt_fine_valida'] as String?;

Map<String, dynamic> _$UtenteToJson(Utente instance) {
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
  writeNotNull('profile_id', instance.profileId);
  writeNotNull('username', instance.username);
  writeNotNull('name', instance.name);
  writeNotNull('phone_number', instance.phoneNumber);
  writeNotNull('email', instance.email);
  writeNotNull('punto_vendita', instance.puntoVendita);
  writeNotNull('confermato', instance.confermato);
  writeNotNull('ruolo', instance.ruolo);
  writeNotNull('dt_fine_valida', instance.dtFineValidita);
  return val;
}
