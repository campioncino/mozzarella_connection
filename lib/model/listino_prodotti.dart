import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'listino_prodotti.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ListinoProdotti extends WSResponse {
  static const String TABLE_NAME = "listini_prodotti";
  ListinoProdotti();

  factory ListinoProdotti.fromJson(Map<String, dynamic> json) =>
      _$ListinoProdottiFromJson(json);

  Map<String, dynamic> toJson() => _$ListinoProdottiToJson(this);

  @JsonKey(name: 'prod_id')
  int? prodId;
  @JsonKey(name: 'list_id')
  int? listId;
  num? price;
  int? sku;

  @override
  ListinoProdotti.fromDBMap(Map map) {
    this.prodId = map['prod_id'];
    this.listId = map['list_id'];
    this.price = map['price'];
    this.sku = map['sku'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.prodId != null) {
      map['prod_id'] = this.prodId;
    }
    map['list_id']=this.listId ;
    map['price']=this.price ;
    map['sku']=this.sku ;
    return map;
  }
}