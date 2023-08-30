import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:json_annotation/json_annotation.dart';

part 'report_ddt_prodotto.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ReportDdtProtto {
  ReportDdtProtto();

  factory ReportDdtProtto.fromJson(Map<String, dynamic> json) =>
      _$ReportDdtProttoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDdtProttoToJson(this);

  @JsonKey(name: 'id')
  int? id;
  @JsonKey(name: 'sku')
  int? sku;
  @JsonKey(name: 'note')
  String? note;
  @JsonKey(name: 'price')
  num? price;
  @JsonKey(name: 'codice')
  String? codice;
  @JsonKey(name: 'list_id')
  int? listId;
  @JsonKey(name: 'prod_id')
  int? prodId;
  @JsonKey(name: 'order_id')
  int? orderId;
  @JsonKey(name: 'quantita')
  int? quantita;
  @JsonKey(name: 'image_url')
  String? imageUrl;
  @JsonKey(name: 'created_at')
  DateTime? createdAt;
  @JsonKey(name: 'dt_fin_val')
  DateTime? dtFinVal;
  @JsonKey(name: 'descrizione')
  String? descrizione;
  @JsonKey(name: 'stato_codice')
  String? statoCodice;
  @JsonKey(name: 'denominazione')
  String? denominazione;
  @JsonKey(name: 'unimis_codice')
  String? unimisCodice;
  @JsonKey(name: 'dt_inserimento')
  DateTime? dtInserimento;
  @JsonKey(name: 'qta_produzione')
  int? qtaProduzione;
  @JsonKey(name: 'tip_prod_codice')
  String? tipProdCodice;
  @JsonKey(name: 'unimis_produzione')
  String? unimisProduzione;
  @JsonKey(name: 'cat_prodotto_codice')
  String? catProdottoCodice;


  @override
  ReportDdtProtto.fromDBMap(Map map) {

    this.id = map['id'];
    this.sku = map['sku'];
    this.note = map['note'];
    this.price = map['price'];
    this.codice = map['codice'];
    this.listId = map['list_id'];
    this.prodId = map['prod_id'];
    this.orderId = map['order_id'];
    this.quantita = map['quantita'];
    this.imageUrl = map['image_url'];
    this.createdAt = map['created_at'];
    this.dtFinVal = map['dt_fin_val'];
    this.descrizione = map['descrizione'];
    this. statoCodice = map['stato_codice'];
    this. denominazione = map['denominazione'];
    this. unimisCodice = map['unimis_codice'];
    this.dtInserimento = map['dt_inserimento'];
    this. qtaProduzione = map['qta_produzione'];
    this. tipProdCodice = map['tip_prod_codice'];
    this. unimisProduzione = map['unimis_produzione'];
    this. catProdottoCodice = map['cat_prodotto_codice'];

  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();

     map['id'] = this.id;
     map['sku'] = this.sku;
     map['note'] = this.note;
     map['price'] = this.price;
     map['codice'] = this.codice;
     map['list_id'] = this.listId;
     map['prod_id'] = this.prodId;
     map['order_id'] = this.orderId;
     map['quantita'] = this.quantita;
     map['image_url'] = this.imageUrl;
     map['created_at'] = this.createdAt;
     map['dt_fin_val'] = this.dtFinVal;
     map['descrizione'] = this.descrizione;
     map['stato_codice'] = this. statoCodice;
     map['denominazione'] = this. denominazione;
     map['unimis_codice'] = this. unimisCodice;
     map['dt_inserimento'] = this.dtInserimento;
     map['qta_produzione'] = this. qtaProduzione;
     map['tip_prod_codice'] = this. tipProdCodice;
     map['unimis_produzione'] = this. unimisProduzione;
     map['cat_prodotto_codice'] = this. catProdottoCodice;
    return map;
  }
}