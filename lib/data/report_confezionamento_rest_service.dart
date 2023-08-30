import 'package:bufalabuona/main.dart';
// import 'package:bufalabuona/model/report_confezionamento_json_data.dart';
import 'package:bufalabuona/model/report_ddt.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/report_confezionamento.dart';
import '../model/report_ddt_prodotto.dart';
import '../model/ws_error_response.dart';
import '../model/ws_response.dart';
import '../utils/app_utils.dart';

class ReportConfezionamentoRestService {
  BuildContext context;

  static ReportConfezionamentoRestService? _instance;

  factory ReportConfezionamentoRestService(context) =>
      _instance ?? ReportConfezionamentoRestService.internal(context);

  ReportConfezionamentoRestService.internal(this.context);


  Future<WSResponse> getAllReportConfezionamento() async {
    WSResponse result = new WSResponse();
    try {
      var response = await Supabase.instance.client
          .from(ReportConfezionamento.TABLE_NAME)
          .select()
          .order('data_trasporto', ascending: false);

      if (response != null) {
        result = AppUtils.parseWSResponse(response);
      }
    } catch (e) {
      WSErrorResponse err = new WSErrorResponse();
      err.message = e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
    return result;
  }


  Future<WSResponse> getReportConfezionamentoByDate(String date) async {
    WSResponse result = new WSResponse();
    try {
      var response = await Supabase.instance.client
          .from(ReportConfezionamento.TABLE_NAME)
          .select().eq('data_trasporto', date)
          .order('data_trasporto', ascending: false);

      if (response != null) {
        result = AppUtils.parseWSResponse(response);
      }
    } catch (e) {
      WSErrorResponse err = new WSErrorResponse();
      err.message = e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
    return result;
  }

  List<ReportConfezionamento> parseList(List responseBody) {
    List<ReportConfezionamento> list = responseBody
        .map<ReportConfezionamento>((f) => ReportConfezionamento.fromJson(f))
        .toList();
    // ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<WSResponse> getReportConfezionamento(String? data) async {
    WSResponse result = new WSResponse();
    try {
      var response = await Supabase.instance.client.rpc("func_report_confezionamento",params: {'data_report': data});
      if (response != null) {
        result = AppUtils.parseWSResponse(response);
      }
    }
    catch (e) {
      WSErrorResponse err = new WSErrorResponse();
      err.message = e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
    return result;
  }

  Future<WSResponse> upsertReport(ReportConfezionamento report) async{
    supabase.auth.currentSession;
    WSResponse result = new WSResponse();
    Map<dynamic,dynamic> tmp = AppUtils.removeNull(report.tableMap());
    try {
      var response = await supabase
          .from(ReportConfezionamento.TABLE_NAME)
          .insert(tmp).select();

      if(response!=null) {
        result = AppUtils.parseWSUpsertResponse(parseList(response));
      }

    }catch(e){

      result.success=false;
      WSErrorResponse err = new WSErrorResponse();
      err.message= e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }

    return result;
  }


  Future<WSResponse> updateDataTrasporto(ReportConfezionamento report) async{
    supabase.auth.currentSession;
    WSResponse result = new WSResponse();
    // Map<dynamic,dynamic> tmp = AppUtils.removeNull(report.tableMap());

    try {
      var response = await supabase
          .from(ReportConfezionamento.TABLE_NAME)
          .update({'data_trasporto':report.dataTrasporto.toString()})
          .eq('report_id',report.reportId)
          .select();

      if(response!=null) {
        result = AppUtils.parseWSUpsertResponse(parseList(response));
      }

    }catch(e){

      result.success=false;
      WSErrorResponse err = new WSErrorResponse();
      err.message= e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }

    return result;
  }

  List<ReportDdtProtto> parseDdtInfo(List responseBody) {
    List<ReportDdtProtto> list = responseBody
        .map<ReportDdtProtto>((f) => ReportDdtProtto.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<WSResponse> getDDTOrdine(num? numero) async {
    WSResponse result = new WSResponse();
    try {
      var response = await Supabase.instance.client
          .from(ReportConfezionamento.TABLE_NAME)
          .select().eq('numero_ordine', numero)
          .order('data_trasporto', ascending: false);

      if (response != null) {
        result = AppUtils.parseWSResponse(response);
      }
    } catch (e) {
      WSErrorResponse err = new WSErrorResponse();
      err.message = e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
    return result;
  }

  Future<WSResponse> generateDDTOrdine(num? numero) async {
    WSResponse result = new WSResponse();
    try {
      var response = await Supabase.instance.client.rpc("func_generate_ddt",params: {'numero_ordine': numero});
      if (response != null) {
        result = AppUtils.parseWSResponse(response);
      }
    }
    catch (e) {
      WSErrorResponse err = new WSErrorResponse();
      err.message = e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
    return result;
  }

  List<ReportDdt> parseDDTList(List responseBody) {
    List<ReportDdt> list = responseBody
        .map<ReportDdt>((f) => ReportDdt.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }
}