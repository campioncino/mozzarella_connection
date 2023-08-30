import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'categoria.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Categoria extends WSResponse {

  static const String TABLE_NAME = "categorie";
  Categoria();

  factory Categoria.fromJson(Map<String, dynamic> json) =>
      _$CategoriaFromJson(json);

  Map<String, dynamic> toJson() => _$CategoriaToJson(this);

  int? id;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'descrizione')
  String? descrizione;
  @JsonKey(name: 'dt_fin_val')
  String? dtFinVal;
  @JsonKey(name: 'codice')
  String? codice;


  @override
  Categoria.fromDBMap(Map map) {
    this.id = map['id'];
    this.createdAt = map['created_at'];
    this.descrizione = map['descrizione'];
    this.dtFinVal = map['dt_fin_val'];
    this.codice = map['codice'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
    map['created_at']=this.createdAt ;
    map['descrizione']=this.descrizione ;
    map['dt_fin_val']=this.dtFinVal ;
    map['codice']=this.codice;
    return map;
  }
}