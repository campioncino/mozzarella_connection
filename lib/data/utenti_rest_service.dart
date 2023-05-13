
import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/categoria.dart';

class UtentiRestService {
  BuildContext context;

  static UtentiRestService? _instance;

  factory UtentiRestService(context) =>
      _instance ?? UtentiRestService.internal(context);

  UtentiRestService.internal(this.context);

  Future<List<Utente>?> getAllUtenti() async{
    try{
      var response = await Supabase.instance.client
          .from(Utente.TABLE_NAME)
          .select()
      // .order('prod_id', ascending: true)
          ;

      if(response!=null){
        return parseList(response.data.toList());
      }
    }catch(e){
      debugPrint("error :${e.toString()}");
      return null;
    }
  }

  Future<WSResponse> getAll() async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Utente.TABLE_NAME)
          .select()
          ;
      if(response!=null){
      result = AppUtils.parseWSResponse(response);}
    }catch(e){
      WSErrorResponse err = new WSErrorResponse();
      err.message=e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
    return result;
  }

  List<Utente> parseList(List responseBody) {
    List<Utente> list = responseBody
        .map<Utente>((f) => Utente.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<Utente?> getUtente(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(Utente.TABLE_NAME)
          .select()
          .eq('id',id)
          .order('id', ascending: true)
          ;

      if(response!=null){
        return Utente.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");
      return null;
    }
  }

  Future<bool> upsertUtente(Utente item) async{
    try{
      var response = await Supabase.instance.client
          .from(Utente.TABLE_NAME)
          .upsert(item.tableMap())
          ;
      if (response.error == null) {
        // throw "Update profile failed: ${response.error!.message}";
        return true;
      }else{
        return false;
      }

    }catch(e){
      debugPrint("error :${e.toString()}");
      return false;
    }
  }

  }