import 'dart:core';

import 'package:bufalabuona/model/listino_prodotti.dart';
import 'package:json_annotation/json_annotation.dart';
import 'ws_response.dart';
import 'ws_error_response.dart';
part 'listino_prodotti_ext.g.dart';

@JsonSerializable(
  includeIfNull: false,
  explicitToJson: true,
)
class ListinoProdottiExt extends ListinoProdotti {
  static const String TABLE_NAME = "v_listini_prodotti";

  ListinoProdottiExt();

  factory ListinoProdottiExt.fromJson(Map<String, dynamic> json) =>
      _$ListinoProdottiExtFromJson(json);

  Map<String, dynamic> toJson() => _$ListinoProdottiExtToJson(this);

  @JsonKey(name: 'cat_id')
  int? catId;
  @JsonKey(name: 'cat_descrizione')
  String? catDescrizione;
  @JsonKey(name: 'cat_dt_fin_val')
  String? catDtFinVal;
  @JsonKey(name: 'prod_codice')
  String? prodCodice;
  @JsonKey(name: 'prod_denominazione')
  String? prodDenominazione;
  @JsonKey(name: 'prod_descrizione')
  String? prodDescrzione;
  @JsonKey(name: 'prod_quantita')
  int? prodQuantita;
  @JsonKey(name: 'prod_unimis_codice')
  String? prodUnimisCodice;
  @JsonKey(name: 'prod_dt_iniserimento')
  String? prodDtInserimento;
  @JsonKey(name: 'prod_dt_fin_val')
  String? prodDtFinVal;
  @JsonKey(name: 'list_descrizione')
  String? listDescrzione;
  @JsonKey(name: 'list_note')
  String? listNote;
  @JsonKey(name: 'list_fin_val')
  String? listFinVal;
  @JsonKey(name: 'list_ini_val')
  String? listIniVal;
  @JsonKey(name:'prod_unimis_descrizione')
  String? prodUnimisDescrizione;
  @JsonKey(name:'image_url')
  String? imageUrl;
}