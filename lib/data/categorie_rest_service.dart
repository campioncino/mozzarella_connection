
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
          .execute();

      if(response.data!=null){
        return parseList(response.data.toList());
      }
    }catch(e){
      debugPrint(e.toString());
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

  Future<CartItem?> getCartItem(int id) async{
    try{
      var response = await Supabase.instance.client
          .from(CartItem.TABLE_NAME)
          .select()
          .eq('id',id)
      // .order('prod_id', ascending: true)
          .execute();

      if(response.data!=null){
        return CartItem.fromJson(response.data);
      }
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> upsertCartItem(CartItem cartItem) async{
    try{
      var response = await Supabase.instance.client
          .from(CartItem.TABLE_NAME)
          .upsert(cartItem.tableMap())
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