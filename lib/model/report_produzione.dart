import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'report_produzione.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ReportProduzione extends WSResponse {
  static const String TABLE_NAME = "report_produzione";
  ReportProduzione();

  factory ReportProduzione.fromJson(Map<String, dynamic> json) =>
      _$ReportProduzioneFromJson(json);

  Map<String, dynamic> toJson() => _$ReportProduzioneToJson(this);
  @JsonKey(name: 'report_id')
  int? reportId;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(
      name: 'data_riferimento',
      fromJson: AppUtils.stringToDatePostgres,
      toJson: AppUtils.dateToString)
  DateTime? dtRiferimento;
  @JsonKey(name: 'products_data')
  String? productsData;
  String? hash;
  String? note;
  int? index;


  @override
  ReportProduzione.fromDBMap(Map map) {
    this.reportId = map['report_id'];
    this.createdAt = map['created_at'];
    this.dtRiferimento = map['data_riferimento'];
    this.productsData = map['products_data'];
    this.hash = map['hash'];
    this.note = map['note'];
    this.index = map['index'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.reportId != null) {
      map['report_id'] = this.reportId;
    }
    map['created_at']=this.createdAt ;
    map['data_riferimento']=this.dtRiferimento.toString() ;
    map['products_data'] = this.productsData;
    map['hash']=this.hash;
    map['note'] = this.note;
    map['index'] = this.index;
    return map;
  }
}