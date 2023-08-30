import 'package:bufalabuona/model/prodotto.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdottiRestService {
  BuildContext context;

  static ProdottiRestService? _instance;

  factory ProdottiRestService(context) =>
      _instance ?? ProdottiRestService.internal(context);

  ProdottiRestService.internal(this.context);

  Future<List<Prodotto>?> getAllProdotti({String? orderBy,bool? ascending}) async{
    try{
      var response = await Supabase.instance.client
          .from(Prodotto.TABLE_NAME)
          .select()
          .order(orderBy??'denominazione', ascending: ascending??true)  //comunque non mi piace
          ;

      if(response.data!=null){
        return parseList(response.data.toList());
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  Future<WSResponse> getAll({String? orderBy,bool? ascending}) async{
    WSResponse result = new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Prodotto.TABLE_NAME)
          .select()
          .order(orderBy??'denominazione', ascending: ascending??true)  //comunque non mi piace
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




  List<Prodotto> parseList(List responseBody) {
    List<Prodotto> list = responseBody
        .map<Prodotto>((f) => Prodotto.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<Prodotto?> getProdotto(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(Prodotto.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          ;

      if(response!=null){
        return Prodotto.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  Future<WSResponse> updateProdotto(Prodotto prodotto) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Prodotto.TABLE_NAME)
          .upsert(prodotto.tableMap())
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

  Future<WSResponse> insertProdotto(Prodotto item) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(Prodotto.TABLE_NAME)
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


  Future<WSResponse> updateProdottoAvatar(String imageUrl,Prodotto item) async {
    item.imageUrl=imageUrl;
    return await updateProdotto(item);
  }


  }