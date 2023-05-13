
import 'dart:convert';

import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/ws_error_response.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/cart_item.dart';

class CartItemRestService {
  BuildContext context;

  static CartItemRestService? _instance;

  factory CartItemRestService(context) =>
      _instance ?? CartItemRestService.internal(context);

  CartItemRestService.internal(this.context);

  Future<List<CartItem>?> getAllCartItem() async{
    try{
      var response = await Supabase.instance.client
          .from(CartItem.TABLE_NAME)
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

  List<CartItem> parseList(List responseBody) {
    List<CartItem> list = responseBody
        .map<CartItem>((f) => CartItem.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  List<CartItemExt> parseListExt(List responseBody) {
    List<CartItemExt> list = responseBody
        .map<CartItemExt>((f) => CartItemExt.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<CartItem?> getCartItem(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(CartItem.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
      ;

      if(response!=null){
        return CartItem.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  Future<bool> upsertCartItem(CartItem cartItem) async{
    try{
      var response = await Supabase.instance.client
          .from(CartItem.TABLE_NAME)
          .upsert(cartItem.tableMap());
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

  /// A QUANTO PARE L'UPSERT non gestisce INSERT E UPDATE CON ID NULL ...e allora a che cazzo serve?
  Future<WSResponse> upsertMultipleCartItem(List<CartItem> listItem) async{
    WSResponse result = new WSResponse();
    var o=AppUtils.removeNull(listItem.map((e) => e.tableMap()).toList());
    try{
      var response = await Supabase.instance.client
          .from(CartItem.TABLE_NAME)
          .upsert(o).select();
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


  Future<WSResponse> insertMultipleCartItem(List<CartItem> listItem) async{
    WSResponse result = new WSResponse();
    var o=AppUtils.removeNull(listItem.map((e) => e.tableMap()).toList());
    try{
      var response = await Supabase.instance.client
          .from(CartItem.TABLE_NAME)
          .insert(o).select();
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


  Future<WSResponse> getCartItemByOrdineId(int id) async{
    WSResponse result = new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(CartItemExt.TABLE_NAME)
          .select()
          .eq('order_id',id)
      // .order('prod_id', ascending: true)
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

  Future<WSResponse> getCartItemExtByOrdineId(int id) async{
    WSResponse result = new WSResponse();
    try{
      var response = await Supabase.instance.client
          .from(CartItemExt.TABLE_NAME)
          .select()
          .eq('order_id',id)
      // .order('prod_id', ascending: true)
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