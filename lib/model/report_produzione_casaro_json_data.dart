import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'report_produzione_casaro_json_data.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ReportProduzioneCasaroJsonData {
  ReportProduzioneCasaroJsonData();

  factory ReportProduzioneCasaroJsonData.fromJson(Map<String, dynamic> json) =>
      _$ReportProduzioneCasaroJsonDataFromJson(json);

  Map<String, dynamic> toJson() => _$ReportProduzioneCasaroJsonDataToJson(this);
  int? totale;
  String? dettaglio;
  @JsonKey(name: 'tip_prod_codice')
  String? tipProdCodice;
  @JsonKey(name: 'unimis_produzione')
  String? unimisProduzione;
  @JsonKey(name: 'tip_prod_descrizione')
  String? tipProdDescrizione;
  @JsonKey(name: 'qta_produzione')
  int? qtaProduzione;


  @override
  ReportProduzioneCasaroJsonData.fromDBMap(Map map) {
    this.totale = map['totale'];
    this.dettaglio = map['dettaglio'];
    this.tipProdCodice = map['tip_prod_codice'];
    this.unimisProduzione = map['unimis_produzione'];
    this.tipProdDescrizione = map['tip_prod_descrizione'];
    this.qtaProduzione = map['qta_produzione'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.tipProdCodice != null) {
      map['tip_prod_codice'] = this.tipProdCodice;
    }
    map['toale']=this.totale ;
    map['dettaglio']=this.dettaglio;
    map['unimis_produzione'] = this.unimisProduzione;
    map['tip_prod_descrizione']=this.tipProdDescrizione;
    map['qta_produzione']=this.qtaProduzione;
    return map;
  }
}