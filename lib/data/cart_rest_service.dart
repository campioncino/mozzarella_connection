
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/cart.dart';

class CartRestService {
  BuildContext context;

  static CartRestService? _instance;

  factory CartRestService(context) =>
      _instance ?? CartRestService.internal(context);

  CartRestService.internal(this.context);

  Future<List<Cart>?> getAllCart() async{
    try{
      var response = await Supabase.instance.client
          .from(Cart.TABLE_NAME)
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

  List<Cart> parseList(List responseBody) {
    List<Cart> list = responseBody
        .map<Cart>((f) => Cart.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  Future<Cart?> getCart(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(Cart.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          ;

      if(response!=null){
        return Cart.fromJson(response);
      }
    }catch(e){
      debugPrint("error :${e.toString()}");

      return null;
    }
  }

  Future<bool> upsertCart(Cart cart) async{
    try{
      var response = await Supabase.instance.client
          .from(Cart.TABLE_NAME)
          .upsert(cart.tableMap())
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