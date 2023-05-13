
import 'package:bufalabuona/model/categoria_prodotto.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/categoria.dart';
import '../model/listino.dart';

class CategorieProdottiRestService {
  BuildContext context;

  static CategorieProdottiRestService? _instance;

  factory CategorieProdottiRestService(context) =>
      _instance ?? CategorieProdottiRestService.internal(context);

  CategorieProdottiRestService.internal(this.context);

  Future<WSResponse> getAll() async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(CategoriaProdotto.TABLE_NAME)
          .select()
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

  List<CategoriaProdotto> parseList(List responseBody) {
    List<CategoriaProdotto> list = responseBody
        .map<CategoriaProdotto>((f) => CategoriaProdotto.fromJson(f))
        .toList();
    return list;
  }

  Future<CategoriaProdotto?> getCategoriaProdotto(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(CategoriaProdotto.TABLE_NAME)
          .select()
          .eq('id',id)       ;

      if(response!=null){
        return CategoriaProdotto.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  Future<WSResponse> getCategoriaProdottoByCatId(int id) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(CategoriaProdotto.TABLE_NAME)
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

    Future<WSResponse> upsertCategoriaProdotto(CategoriaProdotto item) async{
      WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(CategoriaProdotto.TABLE_NAME)
          .upsert(AppUtils.removeNull(item.tableMap()))
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