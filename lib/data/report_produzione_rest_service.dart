import 'package:bufalabuona/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/report_produzione.dart';
import '../model/report_produzione_json_data.dart';
import '../model/ws_error_response.dart';
import '../model/ws_response.dart';
import '../utils/app_utils.dart';

class ReportProduzioneRestService {
  BuildContext context;

  static ReportProduzioneRestService? _instance;

  factory ReportProduzioneRestService(context) =>
      _instance ?? ReportProduzioneRestService.internal(context);

  ReportProduzioneRestService.internal(this.context);


  Future<WSResponse> getAllReportProduzione() async {
    WSResponse result = new WSResponse();
    try {
      var response = await Supabase.instance.client
          .from(ReportProduzione.TABLE_NAME)
          .select()
          .order('data_riferimento', ascending: false);

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


  Future<WSResponse> getReportProduzioneByDate(String date) async {
    WSResponse result = new WSResponse();
    try {
      var response = await Supabase.instance.client
          .from(ReportProduzione.TABLE_NAME)
          .select().eq('data_riferimento', date)
          .order('data_riferimento', ascending: false);

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

  List<ReportProduzione> parseList(List responseBody) {
    List<ReportProduzione> list = responseBody
        .map<ReportProduzione>((f) => ReportProduzione.fromJson(f))
        .toList();
    // ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<WSResponse> getReportProduzione(String? data) async {
    WSResponse result = new WSResponse();
    try {
      var response = await Supabase.instance.client.rpc("func_report_produzione",params: {'data_report': data});
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

  Future<WSResponse> upsertOrdine(ReportProduzione report) async{
    supabase.auth.currentSession;
    WSResponse result = new WSResponse();
    Map<dynamic,dynamic> tmp = AppUtils.removeNull(report.tableMap());
    try {
      var response = await supabase
          .from(ReportProduzione.TABLE_NAME)
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


  List<ReportProduzioneJsonData> parseJsonDataList(List responseBody) {
    List<ReportProduzioneJsonData> list = responseBody
        .map<ReportProduzioneJsonData>((f) => ReportProduzioneJsonData.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }
}