import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'ordine.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Ordine extends WSResponse {
  static const String TABLE_NAME = "ordini";
  Ordine();

  factory Ordine.fromJson(Map<String, dynamic> json) =>
      _$OrdineFromJson(json);

  Map<String, dynamic> toJson() => _$OrdineToJson(this);

  int? id;
  @JsonKey(name: 'utente_id')
  String? utenteId;
  @JsonKey(name: 'cart_id')
  int? cartId;
  @JsonKey(name: 'pvendita_id')
  int? pvenditaId;
  @JsonKey(name: 'stato_codice')
  String? statoCodice;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(
      name: 'data_consegna',
      fromJson: AppUtils.stringToDatePostgres,
      toJson: AppUtils.dateToString)
  DateTime? dtConsegna;
  @JsonKey(name: 'indirizzo_consegna')
  String? indirizzoConsegna;
  String? note;
  num? total;
  num? numero;
  @JsonKey(name: 'tipo_fiscale_codice')
  String? tipoFiscaleCodice;
  @JsonKey(name: 'modified_at')
  String? modifiedAt;


  @override
  Ordine.fromDBMap(Map map) {
    this.id = map['id'];
    this.cartId = map['cart_id'];
    this.pvenditaId = map['pvendita_id'];
    this.utenteId = map['utente_id'];
    this.statoCodice = map['stato_codice'];
    this.dtConsegna = map['data_consegna'];
    this.createdAt = map['created_at'];
    this.total = map['total'];
    this.indirizzoConsegna = map['indirizzo_consegna'];
    this.note = map['note'];
    this.tipoFiscaleCodice = map['tipo_fiscale_codice'];
    this.modifiedAt = map['modified_at'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
    map['cart_id'] = this.cartId;
    map['pvendita_id'] = this.pvenditaId;
    map['utente_id']=this.utenteId;
    map['stato_codice']=this.statoCodice ;
    map['data_consegna']=this.dtConsegna.toString() ;
    map['created_at']=this.createdAt ;
    map['total']=this.total ;
    map['indirizzo_consegna']=this.indirizzoConsegna;
    map['note'] = this.note;
    map['tipo_fiscale_codice'] = this.tipoFiscaleCodice;
    map['modified_at']=this.modifiedAt;
    return map;
  }
}