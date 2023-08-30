import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';

import 'ordine.dart';
part 'ordine_ext.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class OrdineExt extends Ordine {
  static const String TABLE_NAME = "v_ordini";
  OrdineExt();

  factory OrdineExt.fromJson(Map<String, dynamic> json) =>
      _$OrdineExtFromJson(json);

  Map<String, dynamic> toJson() => _$OrdineExtToJson(this);

  @JsonKey(name: 'utente_name')
  String? utenteName;

  @JsonKey(name: 'utente_email')
  String? utenteEmail;

  @JsonKey(name: 'utente_username')
  String? utenteUsername;

  @JsonKey(name: 'utente_phone_number')
  String? utentePhoneNumber;

  @JsonKey(name: 'pvendita_denominazione')
  String? pvenditaDenominazione;

  @JsonKey(name: 'pvendita_categoria')
  String? pvenditaCatDescrizione;

  @JsonKey(name: 'tipo_fiscale_descrizione')
  String? tipoFiscaleDescrizione;

  @JsonKey(name: 'numero_ddt')
  String? numeroDDT;

  // @override
  // OrdineExt.fromDBMap(Map map) {
  //   this.utenteName = map['utente_name'];
  //   this.utenteEmail = map['utente_email'];
  //   this.utenteUsername = map['utente_username'];
  //   this.utentePhoneNumber = map['utente_phone_number'];
  //   this.pvenditaDenominazione = map['pvendita_denominazione'];
  //   this.pvenditaCatDescrizione = map['pvendita_categoria'];
  // }
  //
  // Map<String, dynamic> tableMap() {
  //   var map = new Map<String, dynamic>();
  //   map['utente_name'] = this.utenteName;
  //   map['utente_email'] = this.utenteEmail;
  //   map['utente_username'] = this.utenteUsername;
  //   map['utente_phone_number'] = this.utentePhoneNumber;
  //   map['pvendita_denominazione'] = this.pvenditaDenominazione;
  //   map['pvendita_categoria'] = this.pvenditaCatDescrizione;
  //   return map;
  // }
}