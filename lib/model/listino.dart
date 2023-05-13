import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'listino.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Listino extends WSResponse {

  static const String TABLE_NAME = "listini";
  Listino();

  factory Listino.fromJson(Map<String, dynamic> json) =>
      _$ListinoFromJson(json);

  Map<String, dynamic> toJson() => _$ListinoToJson(this);

  int? id;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'cat_id')
  int? catId;
  @JsonKey(
      name: 'dt_evento',
      fromJson: AppUtils.stringToDate,
      toJson: AppUtils.dateToString)
  DateTime? dtEvento;
  @JsonKey(name: 'dt_fin_val')
  String? dtFinVal;
  String? descrizione;
  @JsonKey(name: 'dt_ini_val')
  String? dtIniVal;
  String? note;
  bool? active;

  @override
  Listino.fromDBMap(Map map) {
    this.id = map['id'];
    this.createdAt = map['created_at'];
    this.dtIniVal = map['dt_ini_val'];
    this.dtFinVal = map['dt_fin_val'];
    this.descrizione = map['descrizione'];
    this.catId = map['cat_id'];
    this.note = map['note'];
    this.active = map['active'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
    map['created_at'] = this.createdAt ;
    map['dt_ini_val'] = this.dtIniVal ;
    map['dt_fin_val'] = this.dtFinVal ;
    map['descrizione'] = this.descrizione ;
    map['cat_id'] = this.catId ;
    map['active'] = this.active;
    map['note'] = this.note;
    return map;
  }
}