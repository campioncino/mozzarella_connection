import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'categoria.g.dart';

@JsonSerializable()
class Categoria extends WSResponse {

  static const String TABLE_NAME = "catergoria";
  Categoria();

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      _$CategoriaFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriaToJson(this);

  int? id;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'description')
  String? descrizione;
  @JsonKey(name: 'dt_fin_val')
  String? dtFinVal;

  @override
  Categoria.fromDBMap(Map map) {
    this.id = map['id'];
    this.createdAt = map['created_at'];
    this.descrizione = map['description'];
    this.dtFinVal = map['dt_fin_val'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
    map['created_at']=this.createdAt ;
    map['description']=this.descrizione ;
    map['dt_fin_val']=this.dtFinVal ;
    return map;
  }
}