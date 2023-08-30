
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/categoria.dart';

class CategorieRestService {
  BuildContext context;

  static CategorieRestService? _instance;

  factory CategorieRestService(context) =>
      _instance ?? CategorieRestService.internal(context);

  CategorieRestService.internal(this.context);

  Future<WSResponse> getAll() async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Categoria.TABLE_NAME)
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
          ;

      if(response!=null){
        return Categoria.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  // Future<bool> upsertCategoria(Categoria item) async{
  //   try{
  //     var response = await Supabase.instance.client
  //         .from(Categoria.TABLE_NAME)
  //         .upsert(item.tableMap())
  //         ;
  //     if (response.error == null) {
  //       // throw "Update profile failed: ${response.error!.message}";
  //       return true;
  //     }else{
  //       return false;
  //     }
  //
  //   }catch(e){
  //     debugPrint("error :${e.toString()}");
  //
  //     return false;
  //   }
  // }


  Future<WSResponse> upsertCategoria(Categoria item) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Categoria.TABLE_NAME)
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