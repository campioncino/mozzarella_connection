import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'unimis.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Unimis extends WSResponse {
  static const String TABLE_NAME = "unimis";
  Unimis();

  factory Unimis.fromJson(Map<String, dynamic> json) =>
      _$UnimisFromJson(json);

  Map<String, dynamic> toJson() => _$UnimisToJson(this);

  int? id;
  String? codice;
  String? descrizione;

  @override
  Unimis.fromDBMap(Map map) {
    this.id = map['id'];
    this.codice = map['codice'];
    this.descrizione = map['descrizione'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
    map['codice']=this.codice ;
    map['descrizione']=this.descrizione ;
    return map;
  }
}