import 'package:json_annotation/json_annotation.dart';

part 'report_ddt.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ReportDdt {
  ReportDdt();

  factory ReportDdt.fromJson(Map<String, dynamic> json) =>
      _$ReportDdtFromJson(json);

  Map<String, dynamic> toJson() => _$ReportDdtToJson(this);

  String? causale;
  @JsonKey(name: 'data_ddt')
  DateTime? dataDDT;
  @JsonKey(name: 'ddt_info')
  Map<dynamic,dynamic>? ddtInfo;
  @JsonKey(name: 'ddt_numero')
  num? ddtNumero;
  @JsonKey(name: 'note_ordine')
  String? noteOrdine;
  @JsonKey(name: 'numero_ordine')
  num? numeroOrdine;
  @JsonKey(name: 'totale_ordine')
  num? totaleOrdine;
  @JsonKey(name: 'costo_spedizione')
  String? costoSpedizione;
  @JsonKey(name: 'tipo_fatturazione')
  String? tipoFatturazione;
  @JsonKey(name: 'vettore_trasporto')
  String? vettoreTrasporto;
  @JsonKey(name: 'indirizzo_consegna_ordine')
  String? indirizzoConsegnaOrdine;


  @override
  ReportDdt.fromDBMap(Map map) {
    this.causale = map['causale'];
    this.dataDDT = map['data_ddt'];
    this.ddtInfo = map['ddt_info'];
    this.ddtNumero = map['ddt_numero'];
    this.noteOrdine = map['note_ordine'];
    this.numeroOrdine = map['numero_ordine'];
    this.totaleOrdine = map['totale_ordine'];
    this.costoSpedizione = map['costo_spedizione'];
    this.tipoFatturazione = map['tipo_fatturazione'];
    this.vettoreTrasporto = map['vettore_trasporto'];
    this.indirizzoConsegnaOrdine = map['indirizzo_consegna_ordine'];

  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    map['causale'] = this.causale ;
    map['data_ddt'] = this.dataDDT ;
    map['ddt_info'] = this.ddtInfo ;
    map['ddt_numero'] = this.ddtNumero ;
    map['note_ordine'] = this.noteOrdine ;
    map['numero_ordine'] = this.numeroOrdine ;
    map['totale_ordine'] = this.totaleOrdine ;
    map['costo_spedizione'] = this.costoSpedizione ;
    map['tipo_fatturazione'] = this.tipoFatturazione ;
    map['vettore_trasporto'] = this.vettoreTrasporto ;
    map['indirizzo_consegna_ordine'] = this.indirizzoConsegnaOrdine ;
    return map;
  }
}