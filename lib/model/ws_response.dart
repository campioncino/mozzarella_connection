import 'package:json_annotation/json_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'ws_error_response.dart';

part 'ws_response.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class WSResponse {
  factory WSResponse.fromJson(Map<String, dynamic> json) =>
      _$WSResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WSResponseToJson(this);

  WSResponse();

  List<WSErrorResponse>? errors;
  List<dynamic>? data;
  bool? success;
  int? status;
  int? count;
}
