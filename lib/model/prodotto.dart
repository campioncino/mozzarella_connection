import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'prodotto.g.dart';


@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Prodotto extends WSResponse {
  static const String TABLE_NAME = "prodotti";

  Prodotto();

  factory Prodotto.fromJson(Map<String, dynamic> json) =>
      _$ProdottoFromJson(json);

  Map<String, dynamic> toJson() => _$ProdottoToJson(this);
  @JsonKey(name: 'prod_id')
  int? prodId;
  String? codice;
  String? denominazione;
  String? descrizione;
  @JsonKey(name: 'unimis_codice')
  String? unimisCodice;
  @JsonKey(name: 'dt_inserimento')
  String? dtInserimento;
  @JsonKey(name: 'dt_fin_val')
  String? dtFinVal;
  num? quantita;
  @JsonKey(name: 'cat_prodotto_codice')
  String? catProdottoCodice;
  @JsonKey(name: 'image_url')
  String? imageUrl;

  @override
  Prodotto.fromDBMap(Map map) {
    this.prodId = map['prod_id'];
    this.codice = map['codice'];
    this.denominazione = map['denominazione'];
    this.descrizione = map['descrizione'];
    this.unimisCodice = map['unimis_codice'];
    this.dtFinVal = map['dt_fin_val'];
    this.dtInserimento = map['dt_inserimento'];
    this.quantita = map['quantita'];
    this.catProdottoCodice = map['cat_prodotto_codice'];
    this.imageUrl = map['image_url'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.prodId != null) {
      map['prod_id'] = this.prodId;
    }
    map['codice'] = this.codice;
    map['denominazione'] = this.denominazione;
    map['descrizione']=this.descrizione;
    map['unimis_codice']=this.unimisCodice ;
    map['dt_fin_val']=this.dtFinVal ;
    map['dt_inserimento']=this.dtInserimento ;
    map['quantita']=this.quantita ;
    map['cat_prodotto_codice']=this.catProdottoCodice;
    map['image_url']=this.imageUrl;
    return map;
  }
}
