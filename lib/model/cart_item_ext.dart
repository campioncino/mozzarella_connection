import 'package:bufalabuona/model/cart_item.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'cart_item_ext.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class CartItemExt extends CartItem {

  static const String TABLE_NAME = "v_cart_item";

  CartItemExt();

  factory CartItemExt.fromJson(Map<String, dynamic> json) => _$CartItemExtFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemExtToJson(this);

  @JsonKey(name: 'cat_id')
  int? catId;
  @JsonKey(name: 'cat_descrizione')
  String? catDescrizione;
  @JsonKey(name: 'list_id')
  int? listId;
  @JsonKey(name: 'list_descrizione')
  String? listDescrizione;
  num? price;
  @JsonKey(name: 'prod_codice')
  String? prodCodice;
  @JsonKey(name: 'prod_denominazione')
  String? prodDenominazione;
  @JsonKey(name: 'prod_descrizione')
  String? prodDescrizione;
  @JsonKey(name: 'prod_unimis_codice')
  String? prodUnimisCodice;
  @JsonKey(name: 'prod_unimis_descrizione')
  String? prodUnimisDescrizione;

  @override
  CartItemExt.fromDBMap(Map map) {
    this.catId = map['cat_id'];
    this.catDescrizione = map['cat_descrizione'];
    this.listId = map['list_id'];
    this.listDescrizione = map['list_descrizione'];
    this.price = map['price'];
    this.prodCodice = map['prod_codice'];
    this.prodDescrizione = map['prod_descrizione'];
    this.prodDenominazione = map['prod_denominazione'];
    this.prodUnimisCodice= map['prod_unimis_codice'];
    this.prodUnimisDescrizione= map['prod_unimis_descrizione'];

  }

}