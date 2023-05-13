import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'ordini.g.dart';

@JsonSerializable()
class Ordini extends WSResponse {
  static const String TABLE_NAME = "ordini";
  Ordini();

  factory Ordini.fromJson(Map<String, dynamic> json) =>
      _$OrdiniFromJson(json);

  Map<String, dynamic> toJson() => _$OrdiniToJson(this);
  @JsonKey(name: 'ordine_id')
  int? ordineId;
  @JsonKey(name: 'utente_id')
  int? utenteId;
  @JsonKey(name: 'cart_id')
  int? cartId;
  @JsonKey(name: 'stato_codice')
  String? statoCodice;
  @JsonKey(name: 'dt_inserimento')
  String? dtInserimento;
  @JsonKey(name: 'data_consegna')
  String? dtConsegna;
  num? total;

  @override
  Ordini.fromDBMap(Map map) {
    this.ordineId = map['ordine_id'];
    this.cartId = map['cart_id'];
    this.utenteId = map['utente_id'];
    this.statoCodice = map['stato_codice'];
    this.dtConsegna = map['data_consegna'];
    this.dtInserimento = map['dt_inserimento'];
    this.total = map['total'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.ordineId != null) {
      map['ordine_id'] = this.ordineId;
    }
    map['cart_id'] = this.cartId;
    map['utente_id']=this.utenteId;
    map['stato_codice']=this.statoCodice ;
    map['data_consegna']=this.dtConsegna ;
    map['dt_inserimento']=this.dtInserimento ;
    map['total']=this.total ;
    return map;
  }
}