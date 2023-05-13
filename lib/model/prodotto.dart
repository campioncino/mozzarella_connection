import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'prodotti.g.dart';

@JsonSerializable()
class Prodotti extends WSResponse {
  Prodotti();

  factory Prodotti.fromJson(Map<String, dynamic> json) =>
      _$ProdottiFromJson(json);

  Map<String, dynamic> toJson() => _$ProdottiToJson(this);
  @JsonKey(name: 'prod_id')
  int? prodId;
  String? codice;
  String? descrizione;
  @JsonKey(name: 'unimis_codice')
  String? unimisCodice;
  @JsonKey(name: 'dt_inserimento')
  String? dtInserimento;
  @JsonKey(name: 'dt_fin_val')
  String? dtFinVal;
  num? quantita;

  @override
  Prodotti.fromDBMap(Map map) {
    this.prodId = map['prod_id'];
    this.codice = map['codice'];
    this.descrizione = map['descrizione'];
    this.unimisCodice = map['unimis_codice'];
    this.dtFinVal = map['dt_fin_val'];
    this.dtInserimento = map['dt_inserimento'];
    this.quantita = map['quantita'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.prodId != null) {
      map['prod_id'] = this.prodId;
    }
    map['codice'] = this.codice;
    map['descrizione']=this.descrizione;
    map['unimis_codice']=this.unimisCodice ;
    map['dt_fin_val']=this.dtFinVal ;
    map['dt_inserimento']=this.dtInserimento ;
    map['quantita']=this.quantita ;
    return map;
  }
}