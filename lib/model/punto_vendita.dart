import 'package:bufalabuona/model/ws_response.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'punto_vendita.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class PuntoVendita extends WSResponse with EquatableMixin{
  static const String TABLE_NAME = "punti_vendita";
  PuntoVendita();

  factory PuntoVendita.fromJson(Map<String, dynamic> json) => _$PuntoVenditaFromJson(json);

  Map<String, dynamic> toJson() => _$PuntoVenditaToJson(this);

  int? id;
  @JsonKey(name: 'created_at')
  String? createdAt;
  @JsonKey(name: 'partita_iva')
  String? partitaIva;
  String? telefono;
  String? indirizzo;
  @JsonKey(name: 'dt_fin_val')
  String? dtFinVal;
  String? denominazione;
  @JsonKey(name: 'id_fatturazione')
  String? idFatturazione;
  @JsonKey(name: 'cat_id')
  int? catId;
  @JsonKey(name: 'rag_sociale')
  String? ragSociale;
  @JsonKey(name: 'indirizzo_consegna')
  String? indirizzoConsegna;
  @JsonKey(name: 'cap_consegna')
  String? capConsegna;
  @JsonKey(name: 'fl_fattura')
  bool? flFattura;
  @JsonKey(name: 'fl_ricevuta')
  bool? flRicevuta;

  @override
  PuntoVendita.fromDBMap(Map map) {
    this.id = map['id'];
    this.createdAt = map['created_at'];
    this.partitaIva = map['partita_iva'];
    this.indirizzo = map['indirizzo'];
    this.telefono = map['telefono'];
    this.dtFinVal = map['dt_fin_val'];
    this.denominazione = map['denominazione'];
    this.idFatturazione = map['id_fatturazione'];
    this.catId = map['cat_id'];
    this.ragSociale = map['rag_sociale'];
    this.indirizzoConsegna = map['indirizzo_consegna'];
    this.capConsegna = map['cap_consegna'];
    this.flFattura = map['fl_fattura'];
    this.flRicevuta = map['flRicevuta'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }
     map['created_at'] = this.createdAt ;
     map['partita_iva'] = this.partitaIva ;
     map['indirizzo'] = this.indirizzo ;
     map['telefono'] = this.telefono ;
     map['dt_fin_val'] = this.dtFinVal ;
     map['denominazione'] = this.denominazione ;
     map['id_fatturazione'] = this.idFatturazione ;
     map['cat_id'] = this.catId ;
     map['rag_sociale'] = this.ragSociale;
     map['indirizzo_consegna'] = this.indirizzoConsegna;
     map['cap_consegna'] = this.capConsegna;
     map['fl_fattura'] = this.flFattura;
     map['fl_ricevuta'] = this.flRicevuta;
    return map;
  }

  @override
  // TODO: implement props
  List<Object?> get props => [denominazione,partitaIva];
}