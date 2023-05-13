import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'cart.g.dart';
@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Cart extends WSResponse {
  Cart();

  static const String TABLE_NAME = "cart";

  factory Cart.fromJson(Map<String, dynamic> json) =>
      _$CartFromJson(json);

  Map<String, dynamic> toJson() => _$CartToJson(this);

  int? id;
  @JsonKey(name: 'created_at')
  String? createdAt;
  String? expire;
  String? stato;

  @override
  Cart.fromDBMap(Map map) {
    this.id = map['id'];
    this.createdAt = map['created_at'];
    this.expire = map['expire'];
    this.stato = map['status'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
    map['created_at']=this.createdAt ;
    map['expire']=this.expire ;
    map['status']=this.stato ;
    return map;
  }
}