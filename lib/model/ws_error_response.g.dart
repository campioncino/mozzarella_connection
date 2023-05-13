// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ws_error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WSErrorResponse _$WSErrorResponseFromJson(Map<String, dynamic> json) =>
    WSErrorResponse()
      ..field = json['field'] as String?
      ..code = json['code'] as String?
      ..message = json['message'] as String?
      ..index = json['index'] as int?
      ..hint = json['hint'] as String?
      ..details = json['details'] as String?;

Map<String, dynamic> _$WSErrorResponseToJson(WSErrorResponse instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('field', instance.field);
  writeNotNull('code', instance.code);
  writeNotNull('message', instance.message);
  writeNotNull('index', instance.index);
  writeNotNull('hint', instance.hint);
  writeNotNull('details', instance.details);
  return val;
}
