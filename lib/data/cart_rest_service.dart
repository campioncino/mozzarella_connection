import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/prodotto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdiniRestService {
  BuildContext context;

  static OrdiniRestService? _instance;

  factory OrdiniRestService(context) =>
      _instance ?? OrdiniRestService.internal(context);

  OrdiniRestService.internal(this.context);

  Future<List<Ordine>?> getAllOrdini() async{
    try{
      var response = await Supabase.instance.client
          .from(Ordine.TABLE_NAME)
          .select()
      // .order('prod_id', ascending: true)
          .execute();

      if(response.data!=null){
        return parseList(response.data.toList());
      }
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  List<Ordine> parseList(List responseBody) {
    List<Ordine> list = responseBody
        .map<Ordine>((f) => Ordine.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<Ordine?> getOrdine(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(Ordine.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          .execute();

      if(response.data!=null){
        return Ordine.fromJson(response.data);
      }
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> upsertOrdine(Ordine ordine) async{
    try{
      var response = await Supabase.instance.client
          .from(Ordine.TABLE_NAME)
          .upsert(ordine.tableMap())
          .execute();
      if (response.error == null) {
        // throw "Update profile failed: ${response.error!.message}";
        return true;
      }else{
        return false;
      }

    }catch(e){
      debugPrint(e.toString());
      return false;
    }
  }

  }