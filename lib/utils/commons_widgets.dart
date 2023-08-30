import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CommonsWidgets {
  static Widget loadingBody(String title, String subtitle) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(child: CircularProgressIndicator()),
        Container(height: 20.0),
        Text(title),
        Container(height: 5.0),
        Text(
          subtitle,
          textScaleFactor: 0.9,
        ),
      ],
    );
  }

  static Widget errorBody(String? title, {String? message}) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            title ?? '',
            style: TextStyle(color: Colors.red, fontSize: 16.0),
          ),
          Container(height: 5.0),
          Text(
            message ?? '',
            style: TextStyle(color: Colors.red, fontSize: 16.0),
          ),
        ],
      ),
    );
  }

  static Widget updateDialog(BuildContext context, {bool mandatory= false}) {
    var closeApp = () {
      if (!mandatory) {
        Navigator.pop(context);
      } else if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    };

    var openStore = () async {
      late String url;
      if (Platform.isAndroid) {
        url =
            'https://play.google.com/store/apps/details?id=it.izs.flutter.farmaco';
      } else if (Platform.isIOS) {
        url =
            // 'https://itunes.apple.com/us/app/ricetta-elettronica-vet/id1441939495';
             'https://apps.apple.com/it/app/ricetta-elettronica-vet/id1441939495';
      }
      if (await canLaunchUrlString(url)) {
        await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
          // forceSafariVC: false,
        );
        closeApp();
      } else {
        Navigator.pop(context);
      }
    };

    return WillPopScope(
      onWillPop: null,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        title: new Text('Aggiornamento disponibile'),
        content: new Text("È disponibile un nuovo aggiornamento. Accedi allo store per aggiornare l'app all'ultima versione."),
        actions: <Widget>[
          TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.all(15)),
              ),
              child: Text('${mandatory ? 'ESCI' : 'CONTINUA'}'),
              onPressed: () {
                closeApp();
              }),
          TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.all(15)),
              ),
              child:  Text('Vai allo Store'),
              onPressed: () {
                openStore();
              }),
        ],
      ),
    );
  }

  static Widget updateDialogAndroidOldVersions(BuildContext context,
      {String? osVersion}) {
    var openStore = () async {
      late String url;
      if (Platform.isAndroid) {
        url =
            'https://play.google.com/store/apps/details?id=it.izs.flutter.farmaco';
      }
      if (await canLaunchUrlString(url)) {
        await launchUrlString(
          url,
          mode: LaunchMode.externalApplication,
          // forceSafariVC: false,
        );
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
      }
    };

    return new WillPopScope(
      onWillPop: null,
      child: AlertDialog(
        contentPadding: const EdgeInsets.all(16.0),
        title: new Text('ATTENZIONE'),
        content: new Text(
            "La versione Android di questo dispositivo ${osVersion != null ? '($osVersion) ' : ''}"
            "non permette di verificare automaticamente la presenza di aggiornamenti. "
            "\nPremi VERIFICA per controllare manualmente sul Play Store."),
        actions: <Widget>[
          TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.all(15)),
              ),
              child: Text(
                 'ANNULLA'),
              onPressed: () {
                Navigator.pop(context);
              }),
          TextButton(
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.all(15)),
              ),
              child: const Text('VERIFICA'),
              onPressed: () {
                openStore();
              }),
        ],
      ),
    );
  }
}
