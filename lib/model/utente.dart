import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
part 'utente.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Utente extends WSResponse {
  static const String TABLE_NAME = "utenti";
  Utente();

  factory Utente.fromJson(Map<String, dynamic> json) => _$UtenteFromJson(json);

  Map<String, dynamic> toJson() => _$UtenteToJson(this);

  @JsonKey(name:'profile_id')
  String? profileId;
  String? username;
  String? name;
  @JsonKey(name:'phone_number')
  String? phoneNumber;
  String? email;
  @JsonKey(name:'punto_vendita')
  int? puntoVendita;
  bool? confermato;
  String? ruolo;
  @JsonKey(name:'dt_fine_valida')
  String? dtFineValidita;

  @override
  Utente.fromDBMap(Map map) {
    this.profileId = map['profile_id'];
    this.username = map['username'];
    this.name = map['name'];
    this.email = map['email'];
    this.phoneNumber = map['phone_number'];
    this.puntoVendita = map['punto_vendita'];
    this.ruolo = map['ruolo'];
    this.dtFineValidita = map['dt_fine_validita'];
    this.confermato = map['confermato'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.profileId != null) {
      map['profile_id'] = this.profileId;
    }
    map['username']=this.username ;
    map['name']=this.name ;
    map['phone_number'] = this.phoneNumber;
    map['email'] = this.email;
    map['punto_vendita'] = this.puntoVendita;
    map['ruolo'] = this.ruolo;
    map['dt_fine_validita'] = this.dtFineValidita;
    map['confermato'] = this.confermato;
    return map;
  }
}