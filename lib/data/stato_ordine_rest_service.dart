
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/stato_ordine.dart';

class StatoOrdineRestService {
  BuildContext context;

  static StatoOrdineRestService? _instance;

  factory StatoOrdineRestService(context) =>
      _instance ?? StatoOrdineRestService.internal(context);

  StatoOrdineRestService.internal(this.context);

  Future<List<StatoOrdine>?> getAllStatoOrdine() async{
    try{
      var response = await Supabase.instance.client
          .from(StatoOrdine.TABLE_NAME)
          .select()
      // .order('prod_id', ascending: true)
          ;

      if(response!=null){
        return parseList(response.toList());
      }
    }catch(e){
      debugPrint("error :${e.toString()}");
      return null;
    }
  }

  List<StatoOrdine> parseList(List responseBody) {
    List<StatoOrdine> list = responseBody
        .map<StatoOrdine>((f) => StatoOrdine.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<StatoOrdine?> getStatoOrdine(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(StatoOrdine.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          ;

      if(response!=null){
        return StatoOrdine.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");
      return null;
    }
  }

  Future<bool> upsertStatoOrdine(StatoOrdine item) async{
    try{
      var response = await Supabase.instance.client
          .from(StatoOrdine.TABLE_NAME)
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