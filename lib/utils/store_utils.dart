import 'dart:io';

import 'package:bufalabuona/utils/store_rest_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

import 'commons_widgets.dart';

class StoreUtils {
  static Future<bool?> checkVersion(BuildContext context,
      {bool showOldDeviceDialog = false}) async {
    //effettuo il controllo di versione solo in ambito di produzione
    // if (Config.appFlavor == Flavor.STAGING) {
    //   return null;
    // }
    ///DISABILITATO E IMPOSTATO A FALSE PERCHÉ NON SI VA SU IOS PER IL MOMENTO
    if (Platform.isIOS) {
      bool updateAvailable = await StoreRestService.internal(context).checkVersionITunes();
      if (updateAvailable) {
        // _showUpdateDialog(context);
      }
      return updateAvailable;
    }
    else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
      //mostro la dialog per sistemi <21
      if (androidInfo.version.sdkInt! < 21) {
        if (showOldDeviceDialog) {
          showDialog(
              context: context,
              builder: (_) => CommonsWidgets.updateDialogAndroidOldVersions(
                  context,
                  osVersion: androidInfo.version.release));
        }
      } else {
        try {
          AppUpdateInfo state = await InAppUpdate.checkForUpdate();
          if (state.updateAvailability == UpdateAvailability.updateAvailable &&
              state.immediateUpdateAllowed) {
            await InAppUpdate.performImmediateUpdate();
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
    // return null;
  }

  // static void _showUpdateDialog(BuildContext context) {
  //   showDialog(
  //       context: context,
  //       builder: (_) => CommonsWidgets.updateDialog(context, mandatory: false));
  // }
}
