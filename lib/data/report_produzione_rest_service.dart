import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/report_produzione.dart';
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

    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(ReportProduzione.TABLE_NAME)
          .select()
          .order('data_riferimento', ascending: false);

      if(response!=null) {
        result = AppUtils.parseWSResponse(response);
      }

    }catch(e){
      WSErrorResponse err = new WSErrorResponse();
      err.message=e.toString();
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


}