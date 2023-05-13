import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'stato_ordine.g.dart';

@JsonSerializable()
class StatoOrdine extends WSResponse {
  StatoOrdine();

  factory StatoOrdine.fromJson(Map<String, dynamic> json) =>
      _$StatoOrdineFromJson(json);

  Map<String, dynamic> toJson() => _$StatoOrdineToJson(this);
  @JsonKey(name: 'stato_id')
  int? statoId;
  String? codice;
  String? descrizione;

  @override
  StatoOrdine.fromDBMap(Map map) {
    this.statoId = map['stato_id'];
    this.codice = map['codice'];
    this.descrizione = map['descrizione'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.statoId != null) {
      map['stato_id'] = this.statoId;
    }
    map['codice']=this.codice ;
    map['descrizione']=this.descrizione ;
    return map;
  }
}