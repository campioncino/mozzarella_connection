import 'package:bufalabuona/model/prodotto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProdottiRestService {
  BuildContext context;

  static ProdottiRestService? _instance;

  factory ProdottiRestService(context) =>
      _instance ?? ProdottiRestService.internal(context);

  ProdottiRestService.internal(this.context);

  Future<List<Prodotto>?> getAllProdotti() async{
    try{
      var response = await Supabase.instance.client
          .from(Prodotto.TABLE_NAME)
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
          .execute();

      if(response.data!=null){
        return Prodotto.fromJson(response.data);
      }
    }catch(e){
      debugPrint(e.toString());
      return null;
    }
  }

  Future<bool> upsertProdotto(Prodotto prodotto) async{
    try{
      var response = await Supabase.instance.client
          .from(Prodotto.TABLE_NAME)
          .upsert(prodotto.tableMap())
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