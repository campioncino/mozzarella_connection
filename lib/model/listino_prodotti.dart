import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'listini_prodotti.g.dart';

@JsonSerializable()
class ListiniProdotti extends WSResponse {
  ListiniProdotti();

  factory ListiniProdotti.fromJson(Map<String, dynamic> json) =>
      _$ListiniProdottiFromJson(json);

  Map<String, dynamic> toJson() => _$ListiniProdottiToJson(this);

  @JsonKey(name: 'prod_id')
  int? prodId;
  @JsonKey(name: 'list_id')
  String? listId;
  num? price;
  int? sku;

  @override
  ListiniProdotti.fromDBMap(Map map) {
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