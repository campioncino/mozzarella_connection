import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'stato_ordine.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class StatoOrdine extends WSResponse {
  static const String TABLE_NAME = "stato_ordine";
  StatoOrdine();

  factory StatoOrdine.fromJson(Map<String, dynamic> json) =>
      _$StatoOrdineFromJson(json);

  Map<String, dynamic> toJson() => _$StatoOrdineToJson(this);

  int? id;
  String? codice;
  String? descrizione;

  @override
  StatoOrdine.fromDBMap(Map map) {
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