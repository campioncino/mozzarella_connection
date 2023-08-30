// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile()
  ..errors = (json['errors'] as List<dynamic>?)
      ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
      .toList()
  ..data = json['data'] as List<dynamic>?
  ..success = json['success'] as bool?
  ..status = json['status'] as int?
  ..count = json['count'] as int?
  ..id = json['id'] as String?
  ..updatedAt = json['updated_at'] as String?
  ..username = json['username'] as String?
  ..fullName = json['full_name'] as String?
  ..phoneNumber = json['phone_number'] as String?
  ..avatarUrl = json['avatar_url'] as String?
  ..operatorePuntoVendita = json['operatore_punto_vendita'] as bool?
  ..email = json['email'] as String?
  ..note = json['note'] as String?;

Map<String, dynamic> _$ProfileToJson(Profile instance) {
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
  writeNotNull('updated_at', instance.updatedAt);
  writeNotNull('username', instance.username);
  writeNotNull('full_name', instance.fullName);
  writeNotNull('phone_number', instance.phoneNumber);
  writeNotNull('avatar_url', instance.avatarUrl);
  writeNotNull('operatore_punto_vendita', instance.operatorePuntoVendita);
  writeNotNull('email', instance.email);
  writeNotNull('note', instance.note);
  return val;
}
