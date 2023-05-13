
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/categoria.dart';
import '../model/listino.dart';

class ListiniRestService {
  BuildContext context;

  static ListiniRestService? _instance;

  factory ListiniRestService(context) =>
      _instance ?? ListiniRestService.internal(context);

  ListiniRestService.internal(this.context);

  Future<WSResponse> getAll() async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Listino.TABLE_NAME)
          .select()
      // .order('prod_id', ascending: true)
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

  List<Listino> parseList(List responseBody) {
    List<Listino> list = responseBody
        .map<Listino>((f) => Listino.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<Listino?> getListino(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(Listino.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          ;

      if(response!=null){
        return Listino.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  Future<WSResponse> getListinoByCatId(int id) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Listino.TABLE_NAME)
          .select()
          .eq('cat_id',id)
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

    Future<WSResponse> upsertListino(Listino item) async{
      WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Listino.TABLE_NAME)
          .upsert(AppUtils.removeNull(item.tableMap()))
          ;
      if(response!=null) {
        result = AppUtils.parseWSResponse(response);
      }
      // else if(response.error!=null){
      //   WSErrorResponse err = new WSErrorResponse();
      //   err.message=response.error!.message ?? 'errore non gestito';
      //   result.errors ??= [];
      //   result.errors!.add(err);
      // }
    }catch(e){
      WSErrorResponse err = new WSErrorResponse();
      err.message=e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
      return result;
  }

  }