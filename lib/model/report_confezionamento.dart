import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'report_confezionamento.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ReportConfezionamento extends WSResponse {
  static const String TABLE_NAME = "report_confezionamento";
  ReportConfezionamento();

  factory ReportConfezionamento.fromJson(Map<String, dynamic> json) =>
      _$ReportConfezionamentoFromJson(json);

  Map<String, dynamic> toJson() => _$ReportConfezionamentoToJson(this);
  @JsonKey(name: 'report_id')
  int? reportId;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(
      name: 'data_trasporto',
      fromJson: AppUtils.stringToDatePostgres,
      toJson: AppUtils.dateToString)
  DateTime? dataTrasporto;
  @JsonKey(name: 'products_data')
  String? productsData;
  String? hash;
  String? note;
  int? index;
  @JsonKey(name: 'numero_ordine')
  num? numeroOrdine;
  @JsonKey(name: 'numero_ddt')
  String? numeroDdt;


  @override
  ReportConfezionamento.fromDBMap(Map map) {
    this.reportId = map['report_id'];
    this.createdAt = map['created_at'];
    this.dataTrasporto = map['data_trasporto'];
    this.productsData = map['products_data'];
    this.hash = map['hash'];
    this.note = map['note'];
    this.index = map['index'];
    this.numeroDdt = map['numero_ddt'];
    this.numeroOrdine = map['numero_ordine'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.reportId != null) {
      map['report_id'] = this.reportId;
    }
    map['created_at']=this.createdAt ;
    map['data_trasporto']=this.dataTrasporto.toString() ;
    map['products_data'] = this.productsData;
    map['hash']=this.hash;
    map['note'] = this.note;
    map['index'] = this.index;
    map['numero_ddt']=this.numeroDdt;
    map['numero_ordine']=this.numeroOrdine;
    return map;
  }
}