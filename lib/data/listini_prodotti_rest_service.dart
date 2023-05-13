
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

  Future<List<Listino>?> getAllListini() async{
    try{
      var response = await Supabase.instance.client
          .from(Listino.TABLE_NAME)
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
          .execute();

      if(response.data!=null){
        return Listino.fromJson(response.data);
      }
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> upsertListino(Listino item) async{
    try{
      var response = await Supabase.instance.client
          .from(Listino.TABLE_NAME)
          .upsert(item.tableMap())
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