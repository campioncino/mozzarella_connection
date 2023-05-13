
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/categoria.dart';
import '../model/listino.dart';
import '../model/listino_prodotti.dart';
import '../model/listino_prodotti_ext.dart';

class ListiniProdottiRestService {
  BuildContext context;

  static ListiniProdottiRestService? _instance;

  factory ListiniProdottiRestService(context) =>
      _instance ?? ListiniProdottiRestService.internal(context);

  ListiniProdottiRestService.internal(this.context);

  Future<WSResponse> getAll() async {
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdottiExt.TABLE_NAME)
          .select()
      // .order('prod_id', ascending: true)
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

  Future<WSResponse> getAllByCategoria(int catId) async {
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdottiExt.TABLE_NAME)
          .select()
          .eq('cat_id',catId)
          .order('price', ascending: false)
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

  Future<WSResponse> getAllByListId(int listId) async {
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdottiExt.TABLE_NAME)
          .select()
          .eq('list_id',listId)
          .order('price', ascending: false)
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


  Future<List<ListinoProdotti>?> getAllListiniProdotti() async{
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdotti.TABLE_NAME)
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

  List<ListinoProdotti> parseList(List responseBody) {
    List<ListinoProdotti> list = responseBody
        .map<ListinoProdotti>((f) => ListinoProdotti.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  List<ListinoProdottiExt> parseListExt(List responseBody) {
    List<ListinoProdottiExt> list = responseBody
        .map<ListinoProdottiExt>((f) => ListinoProdottiExt.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<ListinoProdotti?> getListinoProdotti(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdotti.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          ;

      if(response!=null){
        return ListinoProdotti.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  Future<WSResponse> getListinoByCatId(int catId) async {
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdottiExt.TABLE_NAME)
          .select('*').eq('cat_id', catId)
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

  Future<WSResponse> upsertListinoProdotti(ListinoProdotti item) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdotti.TABLE_NAME)
          .upsert(item.tableMap()).select()
          ;
      if (response.error == null) {
        // throw "Update profile failed: ${response.error!.message}";
        result = AppUtils.parseWSResponse(response);}
    }catch(e){
      WSErrorResponse err = new WSErrorResponse();
      err.message=e.toString();
      result.errors ??= [];
      result.errors!.add(err);
    }
    return result;
  }


  Future<WSResponse> upsertMassiveListinoProdotti(List<ListinoProdotti> listItem) async{
    WSResponse result=new WSResponse();
    var o=AppUtils.removeNull(listItem.map((e) => e.tableMap()).toList());
    try{

      var response = await Supabase.instance.client
          .from(ListinoProdotti.TABLE_NAME)
          .upsert(o).select();
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

  Future<WSResponse> deleteMassiveListinoProdotti(List<ListinoProdotti> listItem) async{
    WSResponse result=new WSResponse();
    List<int> skus = [];
    listItem.forEach((element) {
      skus.add(element.sku!);
    });
    
    var o=AppUtils.removeNull(listItem.map((e) => e.tableMap()).toList());
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdotti.TABLE_NAME)
          .delete().in_('sku',skus).select();
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

  Future<WSResponse> deleteSingleProdotto(ListinoProdotti item) async{
    WSResponse result=new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(ListinoProdotti.TABLE_NAME)
          .delete().match({'sku':item.sku}).select();
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