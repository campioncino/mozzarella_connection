// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_confezionamento.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportConfezionamento _$ReportConfezionamentoFromJson(
        Map<String, dynamic> json) =>
    ReportConfezionamento()
      ..errors = (json['errors'] as List<dynamic>?)
          ?.map((e) => WSErrorResponse.fromJson(e as Map<String, dynamic>))
          .toList()
      ..data = json['data'] as List<dynamic>?
      ..success = json['success'] as bool?
      ..status = json['status'] as int?
      ..count = json['count'] as int?
      ..reportId = json['report_id'] as int?
      ..createdAt = json['created_at'] as String?
      ..dataTrasporto =
          AppUtils.stringToDatePostgres(json['data_trasporto'] as String?)
      ..productsData = json['products_data'] as String?
      ..hash = json['hash'] as String?
      ..note = json['note'] as String?
      ..index = json['index'] as int?
      ..numeroOrdine = json['numero_ordine'] as num?
      ..numeroDdt = json['numero_ddt'] as String?;

Map<String, dynamic> _$ReportConfezionamentoToJson(
    ReportConfezionamento instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('errors', instance.errors?.map((e) => e.toJson()).toList());
  writeNotNull('data', instance.data);
  writeNotNull('success', instance.success);
  writeNotNull('status', instance.status);
  writeNotNull('count', instance.count);
  writeNotNull('report_id', instance.reportId);
  writeNotNull('created_at', instance.createdAt);
  writeNotNull('data_trasporto', AppUtils.dateToString(instance.dataTrasporto));
  writeNotNull('products_data', instance.productsData);
  writeNotNull('hash', instance.hash);
  writeNotNull('note', instance.note);
  writeNotNull('index', instance.index);
  writeNotNull('numero_ordine', instance.numeroOrdine);
  writeNotNull('numero_ddt', instance.numeroDdt);
  return val;
}
