import 'package:json_annotation/json_annotation.dart';


part 'app.g.dart';

@JsonSerializable(includeIfNull: false, explicitToJson: true)
class App {
  factory App.fromJson(Map<String, dynamic> json) => _$AppFromJson(json);

  Map<String, dynamic> toJson() => _$AppToJson(this);

  App();

  int? id;
  String? nome;
  String? packageName;
  String? descrizione;
  String? versione;
  String? visibile;
}
