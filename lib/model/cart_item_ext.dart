import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'cart_item.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class CartItem extends WSResponse {

  static const String TABLE_NAME = "cart_item";

  CartItem();

  factory CartItem.fromJson(Map<String, dynamic> json) => _$CartItemFromJson(json);

  Map<String, dynamic> toJson() => _$CartItemToJson(this);

  int? id;
  @JsonKey(name: 'created_at')
  String? createdAt;
  // @JsonKey(name: 'cart_id')
  // int? cartId;
  @JsonKey(name: 'order_id')
  int? orderId;
  @JsonKey(name: 'prod_id')
  int? prodId;
  String? stato;
  num? quantita;
  String? note;

  @override
  CartItem.fromDBMap(Map map) {
    this.id = map['id'];
    this.createdAt = map['created_at'];
    // this.cartId = map['cart_id'];
    this.orderId = map['order_id'];
    this.prodId = map['prod_id'];
    this.stato = map['status'];
    this.quantita = map['quantita'];
    this.note = map['note'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
    map['created_at']=this.createdAt ;
    // map['cart_id']=this.cartId ;
    map['order_id'] = this.orderId;
    map['prod_id']=this.prodId ;
    map['quantita']=this.quantita;
    map['status']=this.stato ;
    map['note'] = this.note;
    return map;
  }
}