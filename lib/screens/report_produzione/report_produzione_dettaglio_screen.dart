import 'dart:convert';

import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/data/stato_ordine_rest_service.dart';
import 'package:bufalabuona/model/cart_item.dart';
import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../model/report_produzione.dart';

class ReportProduzioneDettaglioScreen extends StatefulWidget {
  final ReportProduzione? report;
  const ReportProduzioneDettaglioScreen({Key? key,required this.report}) : super(key: key);

  @override
  State<ReportProduzioneDettaglioScreen> createState() => _ReportProduzioneDettaglioScreenState();
}

class _ReportProduzioneDettaglioScreenState extends State<ReportProduzioneDettaglioScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  ReportProduzione? _report;

  List<CartItemExt> _values =[];
  List<CartItemExt> _filteredValues = [];
  bool _isLoading=true;
  bool? _sendOrder = false;
   Map<ListinoProdottiExt,int> _listCart = Map();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _report=this.widget.report;
    _filteredValues.clear();
    init();
  }

  void init() async {
    setState(() {
      _isLoading=false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dettaglio ReportProduzione'),
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: backPressed,
            child: stackWidget()),
      ),
    );
  }

  Widget stackWidget() {
    List<Widget> listWidgets = [];
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    var p = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        body(),
      ],
    );

    listWidgets.add(p);
    return new Stack(children: listWidgets);
  }

  Widget body() {
    return Expanded(child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
       Text("lallero")

      ],
    ));
  }


  Future<void> _refresh() async{
    _filteredValues.clear();
    _values.clear();
  }






    Future<bool> backPressed() async {
      Navigator.pop(context);
      return true;
    }



}
