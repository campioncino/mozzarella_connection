import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';

import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/database_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../model/cart_item_ext.dart';
import '../model/listino_prodotti_ext.dart';

class AppUtils {

  static late Utente utente;
  static late PuntoVendita puntoVendita;

  static const String DATABASE_NAME = 'database.db';


  static Future<File> getDatabaseFile() async {
    String path = await getDatabasePath();
    return new File(path);
  }

  static Future<String> getDatabasePath() async {
    String dir = (await getApplicationDocumentsDirectory()).path;
    return join(dir, DATABASE_NAME);
  }

  static Future<bool> databaseExists() async {
    File dbFile = await getDatabaseFile();
    return dbFile.exists();
  }

  static Future<bool> clearDatabase() async {
    try {
      if (await DatabaseHelper().isOpen()) {
        await DatabaseHelper().close();
      }
    } catch (e) {}
    String path = await getDatabasePath();
    await deleteDatabase(path);
    return true;
  }

  static void errorSnackBar(GlobalKey<ScaffoldMessengerState> key,
      String message) {
    if (key.currentState == null || !key.currentState!.mounted) {
      return;
    }
    final snackBar = SnackBar(
      content: Text(message, style: TextStyle(color: Colors.red),),);
    key.currentState!.showSnackBar(snackBar);
  }

  static Widget loader(BuildContext context) {
    return SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height / 1.3,
      child: const Center(
          child: CircularProgressIndicator()
      ),
    );
  }

  static Widget emptyList(BuildContext context, IconData icon) {
    return SizedBox(
      height: MediaQuery
          .of(context)
          .size
          .height / 1.4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 100, color: Colors.black54,),
          SizedBox(height: 20,),
          const Center(child: Text("Nessun Elemento",
            textAlign: TextAlign.center,
            style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18.0),
          ),),
        ],
      ),
    );
  }

  static String decodeHttpStatus(int? status) {
    String result = "ok";
    switch (status.toString()[0]) {
      case '1' :
        result =
        '[$status] information : the request was received, continuing process';
        break;
      case '2' :
        result =
        '[$status] successful – the request was successfully received, understood, and accepted';
        break;
      case '3' :
        result =
        '[$status] redirection : further action needs to be taken in order to complete the request';
        break;
      case '4':
        result =
        '[$status] client error : the request contains bad syntax or cannot be fulfilled';
        break;
      case '5':
        result =
        '[$status] server error : the server failed to fulfil an apparently valid request';
        break;
    }
    return result;
  }

  static WSResponse parseWSResponse(dynamic response) {
    WSResponse result = new WSResponse();
    if (response != null) {
      result.data = response as List?;
    }
    // if (response. != null) {
    //   WSErrorResponse e = new WSErrorResponse();
    //   e.message = response.error!.message;
    //   e.code = response.error!.code;
    //   e.details = response.error!.details;
    //   e.hint = response.error!.hint;
    //   result.errors = [];
    //   result.errors!.add(e);
    // }
    response != null ? result.success = true : result.success = false;
    return result;
  }

  static WSResponse parseWSUpsertResponse(dynamic response) {
    WSResponse result = new WSResponse();
    if (response != null) {
      result.data = response;
    }
    response != null ? result.success = true : result.success = false;
    return result;
  }

  static stringToDate(String? val) {
    final dateFormatter = new DateFormat('dd-MM-yyyy');
    try {
      return val != null ? dateFormatter.parse(val) : null;
    } catch (e) {}
    return null;
  }

  static  convertTimestamptzToStringDate(String timestamp){
    initializeDateFormatting();
    try {
      final dateFormatter = new DateFormat('dd-MM-yyyy HH:mm:ss');
      final timestamptzsFormatter = new DateFormat("yyyy-MM-ddTHH:mm:ssZ");
      DateTime time = timestamptzsFormatter.parse(timestamp, true);
      return dateFormatter.format(time.toLocal());
    } catch (e) {}
    return null;
  }

  static stringToDatePostgres(String? val) {
    final dateFormatter = new DateFormat('yyyy-MM-dd');
    try {
      return val != null ? dateFormatter.parse(val) : null;
    } catch (e) {}
    return null;
  }

  static dateToString(DateTime? val) {
    final dateFormatter = new DateFormat('dd-MM-yyyy');
    return val != null ? dateFormatter.format(val) : null;
  }


  static formPostgresStringDate(String? val) {
    try {
      return val != null ? DateFormat('dd-MM-yyyy').format(
          DateFormat('yyyy-MM-dd').parse(val)) : null;
    } catch (e) {}
    return null;
  }

  static toPostgresStringDate(String? val) {
    try {
      return val != null ? DateFormat('yyyy-MM-dd').format(
          DateFormat('dd-MM-yyyy').parse(val)) : null;
    } catch (e) {}
    return null;
  }

  static dynamic removeNull(dynamic params) {
    if (params is Map) {
      var _map = {};
      params.forEach((key, value) {
        var _value = removeNull(value);
        if (_value != null) {
          _map[key] = _value;
        }
      });
      // comment this condition if you want empty dictionary
      if (_map.isNotEmpty)
        return _map;
    } else if (params is List) {
      var _list = [];
      for (var val in params) {
        var _value = removeNull(val);
        if (_value != null) {
          _list.add(_value);
        }
      }
      // comment this condition if you want empty list
      if (_list.isNotEmpty)
        return _list;
    } else if (params != null) {
      return params;
    }
    return null;
  }


  static void clearCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("cart");
  }

  static void storeCartItems(Map<ListinoProdottiExt, int> map) async {
    final prefs = await SharedPreferences.getInstance();
    String cart = convertCartToJson(map);
    prefs.setString("cart", cart);
  }

  static Future<Map<ListinoProdottiExt, int>> retrieveCartItems() async {
    Map<ListinoProdottiExt, int> cart ={};
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? json = pref.getString("cart");
    if(json!=null){
    cart = convertCartToMap(json);}
    return cart;
  }
  static void storeFcmToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("fcmToken", token);
  }


  static Future<String?> retrieveFcmToken() async{
    final prefs = await SharedPreferences.getInstance();
    String? fcmToken = prefs.getString("fcmToken");
    return fcmToken;
  }

  static Future<Map<String,dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var deviceData = <String, dynamic>{};
    if (Platform.isAndroid) {
      deviceData = _readAndroidBuildData(await deviceInfoPlugin.androidInfo);
    } else if (Platform.isIOS) {
      deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
    }
    return deviceData;
  }

  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'version.previewSdkInt': build.version.previewSdkInt,
      'version.incremental': build.version.incremental,
      'version.codename': build.version.codename,
      'version.baseOS': build.version.baseOS,
      'board': build.board,
      'bootloader': build.bootloader,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'fingerprint': build.fingerprint,
      'hardware': build.hardware,
      'host': build.host,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
      'supported32BitAbis': build.supported32BitAbis,
      'supported64BitAbis': build.supported64BitAbis,
      'supportedAbis': build.supportedAbis,
      'tags': build.tags,
      'type': build.type,
      'isPhysicalDevice': build.isPhysicalDevice,
      'systemFeatures': build.systemFeatures,
      'displaySizeInches':
      ((build.displayMetrics.sizeInches * 10).roundToDouble() / 10),
      'displayWidthPixels': build.displayMetrics.widthPx,
      'displayWidthInches': build.displayMetrics.widthInches,
      'displayHeightPixels': build.displayMetrics.heightPx,
      'displayHeightInches': build.displayMetrics.heightInches,
      'displayXDpi': build.displayMetrics.xDpi,
      'displayYDpi': build.displayMetrics.yDpi,
    };
  }

  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'identifierForVendor': data.identifierForVendor,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
      'utsname.version:': data.utsname.version,
      'utsname.machine:': data.utsname.machine,
    };
  }

  static String convertCartToJson(Map<ListinoProdottiExt,int> cart){
    List<String> json=[];
    cart.forEach((key, value) {
      ListinoProdottiExt p= key;
      Map<String,dynamic> pj = p.toJson();
      json.add('{"key":'+jsonEncode(pj)+","+ '"value":'+value.toString()+"}");
    });
    print(json.toString());
    return json.toString();
  }

  static Map<ListinoProdottiExt,int>  convertCartToMap(String json){
    Map<ListinoProdottiExt,int> list = {};
    List data = jsonDecode(json);
    data.forEach((element) {
      ListinoProdottiExt tmpL = ListinoProdottiExt.fromJson(element['key']);
      int tmpI = element['value'];
      list[tmpL]=tmpI;
    });

    return list;
  }

  static Map<ListinoProdottiExt,int> convertCartItemToMap(List<CartItemExt> carrello,List<ListinoProdottiExt> listino){
    Map<ListinoProdottiExt,int> result ={};
    carrello.forEach((cart) {
      listino.forEach((list) { if(list.sku == cart.prodId){
        result[list]=int.parse(cart.quantita.toString() ?? '0');
      }});
    });
    return result;
  }

}