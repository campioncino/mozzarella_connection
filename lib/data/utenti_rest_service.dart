
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/categoria.dart';

class CategorieRestService {
  BuildContext context;

  static CategorieRestService? _instance;

  factory CategorieRestService(context) =>
      _instance ?? CategorieRestService.internal(context);

  CategorieRestService.internal(this.context);

  Future<List<Categoria>?> getAllCategorie() async{
    try{
      var response = await Supabase.instance.client
          .from(Categoria.TABLE_NAME)
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

  List<Categoria> parseList(List responseBody) {
    List<Categoria> list = responseBody
        .map<Categoria>((f) => Categoria.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<Categoria?> getCategoria(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(Categoria.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          .execute();

      if(response.data!=null){
        return Categoria.fromJson(response.data);
      }
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> upsertCategoria(Categoria item) async{
    try{
      var response = await Supabase.instance.client
          .from(Categoria.TABLE_NAME)
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