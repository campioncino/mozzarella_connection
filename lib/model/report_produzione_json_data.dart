import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'report_produzione_json_data.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ReportProduzioneJsonData {
  ReportProduzioneJsonData();

  factory ReportProduzioneJsonData.fromJson(Map<String, dynamic> json) =>
      _$ReportProduzioneJsonDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReportProduzioneJsonDataToJson(this);
  @JsonKey(name: 'prod_id')
  int? prodId;
  String? descrizione;
  String? denominazione;
  @JsonKey(name: 'sum_to_deliver')
  int? sumToDeliver;
  @JsonKey(name: 'unimis_codice')
  String? unimisCodice;
  String? codice;


  @override
  ReportProduzioneJsonData.fromDBMap(Map map) {
    this.prodId = map['prod_id'];
    this.descrizione = map['descrizione'];
    this.denominazione = map['descrizione'];
    this.sumToDeliver = map['sum_to_deliver'];
    this.codice = map['codice'];

  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.prodId != null) {
      map['prod_id'] = this.prodId;
    }
    map['sum_to_deliver']=this.sumToDeliver ;
    map['descrizione']=this.descrizione;
    map['denominazione'] = this.denominazione;
    map['codice']=this.codice;
    return map;
  }
}