import 'package:bufalabuona/model/ws_response.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:bufalabuona/model/ws_error_response.dart';

part 'profile.g.dart';
@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class Profile extends WSResponse{

  static const String TABLE_NAME = "profiles";

  Profile();

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  String? id;
  @JsonKey(name:'updated_at')
  String? updatedAt;
  String? username;
  @JsonKey(name:'full_name')
  String? fullName;
  @JsonKey(name:'phone_number')
  String? phoneNumber;
  @JsonKey(name:'avatar_url')
  String? avatarUrl;
  @JsonKey(name:'operatore_punto_vendita')
  bool? operatorePuntoVendita;
  String? email;
  String? note;

  @override
  Profile.fromDBMap(Map map) {
    this.id = map['id'];
    this.username = map['username'];
    this.updatedAt = map['updatedAt'];
    this.email = map['email'];
    this.phoneNumber = map['phone_number'];
    this.operatorePuntoVendita = map['operatore_punto_vendita'];
    this.fullName = map['full_name'];
    this.note=map['note'];
  }

  Map<String, dynamic> tableMap() {
    var map = new Map<String, dynamic>();
    if (this.id != null) {
      map['id'] = this.id;
    }

    map['username'] = this.username;
    map['updatedAt'] = this.updatedAt;
    map['email'] = this.email;
    map['phone_number'] = this.phoneNumber;
    map['operatore_punto_vendita'] = this.operatorePuntoVendita;
    map['full_name'] = this.fullName;
    map['note'] = this.note;
    return map;
  }
}