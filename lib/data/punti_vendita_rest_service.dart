import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PuntiVenditaRestService {
  BuildContext context;

  static PuntiVenditaRestService? _instance;

  factory PuntiVenditaRestService(context) => _instance ?? PuntiVenditaRestService.internal(context);

  PuntiVenditaRestService.internal(this.context);


  Future<PuntoVendita?> getPuntoVendita(int id) async{
      try{
        var response = await Supabase.instance.client
          .from(PuntoVendita.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          ;

        if(response!=null){
          return parseList(response.toList()).first;
        }
      }catch(e){
        debugPrint("error :${e.toString()}");
      return null;
      }
    }

  Future<WSResponse> updatePuntoVendita(PuntoVendita puntoVendita) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(PuntoVendita.TABLE_NAME)
          .upsert(puntoVendita.tableMap())
          ;
      result = AppUtils.parseWSResponse(response);
    }catch(e){
      WSErrorResponse err = new WSErrorResponse();
      err.message=e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
    return result;
  }

  Future<WSResponse> insertPuntoVendita(PuntoVendita item) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(PuntoVendita.TABLE_NAME)
          .insert(item.tableMap())
          ;
          result = AppUtils.parseWSResponse(response);
    }catch(e){
      WSErrorResponse err = new WSErrorResponse();
      err.message=e.toString();
      result.errors ??= [];
      result.errors!.add(err);
      }
    return result;
  }

  Future<WSResponse> getAll() async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
        .from(PuntoVendita.TABLE_NAME)
        .select()
        .order('denominazione', ascending: true)
        ;
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


  List<PuntoVendita> parseList(List responseBody) {
    List<PuntoVendita> list = responseBody
        .map<PuntoVendita>((f) => PuntoVendita.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }
}