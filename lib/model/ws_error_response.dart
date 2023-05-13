import 'package:json_annotation/json_annotation.dart';

part 'ws_error_response.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class WSErrorResponse {

  factory WSErrorResponse.fromJson(Map<String, dynamic> json) => _$WSErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WSErrorResponseToJson(this);


  WSErrorResponse();

  String? field;
  String? code;
  String? message;
  int? index;
  String? hint;
  String? details;

}

