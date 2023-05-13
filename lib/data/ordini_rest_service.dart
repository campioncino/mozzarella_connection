import 'dart:convert';

import 'package:bufalabuona/main.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/ordine_ext.dart';
import 'package:bufalabuona/model/prodotto.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdiniRestService {
  BuildContext context;

  static OrdiniRestService? _instance;

  factory OrdiniRestService(context) =>
      _instance ?? OrdiniRestService.internal(context);

  OrdiniRestService.internal(this.context);


  Future<WSResponse> getAllOrdini(bool confermato) async {
    List<String> stato = ['INVIATO'];
    if(confermato){
      stato.add('CONFERMATO');
    }
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(OrdineExt.TABLE_NAME)
          .select()
          .in_('stato_codice',stato)
          .order('data_consegna', ascending: true);

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


  List<Ordine> parseList(List responseBody) {
    List<Ordine> list = responseBody
        .map<Ordine>((f) => Ordine.fromJson(f))
        .toList();
    // ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  List<OrdineExt> parseListExt(List responseBody) {
    List<OrdineExt> list = responseBody
        .map<OrdineExt>((f) => OrdineExt.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<OrdineExt?> getOrdine(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(OrdineExt.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          ;

      if(response!=null){
        return OrdineExt.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  Future<WSResponse> upsertOrdine(Ordine ordine) async{
    supabase.auth.currentSession;
    WSResponse result = new WSResponse();
    Map<dynamic,dynamic> tmp = AppUtils.removeNull(ordine.tableMap());
    try {
      var response = await supabase
          .from(Ordine.TABLE_NAME)
          .upsert(tmp).select();

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

  Future<WSResponse> updateOrdine(Ordine ordine) async{
    supabase.auth.currentSession;
    WSResponse result = new WSResponse();
    Map<dynamic,dynamic> tmp = AppUtils.removeNull(ordine.tableMap());
    try{
      var response = await supabase
          .from(Ordine.TABLE_NAME)
          .upsert(tmp).select()
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

  Future<WSResponse> getOrdiniByPuntoVenditaId(int? puntoVendita) async {
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(OrdineExt.TABLE_NAME)
          .select()
          .eq('pvendita_id',puntoVendita)
       .order('numero', ascending: false)
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


  }