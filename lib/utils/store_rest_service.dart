import 'dart:async';

import 'package:bufalabuona/model/app.dart';
import 'package:flutter/material.dart';


class StoreRestService {
  BuildContext context;

  static StoreRestService? _instance;

  factory StoreRestService(context) =>
      _instance ?? StoreRestService.internal(context);

  StoreRestService.internal(this.context);

  Future<bool> updateAvailable(String thisVersion, App app) async {
    String newVersion = app.versione!;
    List<int?> thisVersionList =
    thisVersion.split('.').map((s) => int.tryParse(s)).toList();
    List<int?> newVersionList =
    newVersion.split('.').map((s) => int.tryParse(s)).toList();
    if (newVersionList[0]! > thisVersionList[0]!) {
      return true;
    }
    if (newVersionList[1]! > thisVersionList[1]!) {
      return true;
    }
    if (newVersionList[2]! > thisVersionList[2]!) {
      return true;
    }
    return false;
  }

  Future<bool> checkVersionITunes() async {
    return false;
  }
    /*
    String url = 'lookup?bundleId=it.izs.flutter.farmaco&country=it';
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String thisVersion = packageInfo.version;
      Dio dio = new Dio();
      // dio.options.baseUrl = 'http://itunes.apple.com/';
      dio.options.baseUrl = 'http://apps.apple.com/';
      dio.options.contentType = "application/json";
      dio.options.responseType = ResponseType.json;
      Response response = await dio.post(url);
      Map<String, dynamic> data = jsonDecode(response.data);
      String? storeVersion = data['results'][0]['version'];
      if (storeVersion == null) {
        return false;
      }
      App app = new App();
      app.versione = storeVersion;
      return updateAvailable(thisVersion, app);
    } catch (e) {
      return false;
    }
  }
     */
}
