import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'package:bufalabuona/model/report_produzione_json_data.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../data/report_produzione_rest_service.dart';
import '../../model/report_produzione.dart';
import '../../model/ws_response.dart';
import '../../pdf/pdf_api.dart';
import '../../pdf/pdf_report_api.dart';

class DettaglioReportScreen extends StatefulWidget {
  // final WSResponse? data;
  final String? dtReport;
  final List? data;
  final bool? isFromStorico;
  const DettaglioReportScreen({Key? key,required this.data, required this.dtReport, required this.isFromStorico}) : super(key: key);


  @override
  State<DettaglioReportScreen> createState() => _DettaglioReportScreenState();
}

class _DettaglioReportScreenState extends State<DettaglioReportScreen> {
  final dateFormatter = new DateFormat('dd-MM-yyyy');
  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');
  bool _isLoading=true;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final globalKey = GlobalKey<ScaffoldState>();
  String? _dtReport;
  List? _listData;
  List<ReportProduzioneJsonData>? _values;
  List<ReportProduzione> _listSavedReports = [];
  ReportProduzione? _reportProduzione;
  bool? _isFromStorico;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dtReport = this.widget.dtReport;
    _listData= this.widget.data;
    _values= ReportProduzioneRestService.internal(context).parseJsonDataList(_listData!);
    _isFromStorico = this.widget.isFromStorico;
    init();
  }

  void init() async{
    if(! _isFromStorico!){
      await readData();
    }
    // if(! _isFromStorico!){
      await saveReportIfNotExists();
    // }
    setState(() {
      _isLoading=false;
    });
  }



  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
        key: _scaffoldKey,
        child: WillPopScope(
          onWillPop: backPressed,
          child: Scaffold(
            appBar: AppBar(title: Text("Dettaglio Report"),),
              resizeToAvoidBottomInset: false,
              body: stackWidget(),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Colors.amberAccent,
              elevation: 0.0,
              child:  const Icon(Icons.picture_as_pdf_rounded,size: 36,),
              // backgroundColor: const Color(0xFFE57373),
              onPressed:() async =>await _generatePdf()
          ),
          ),
        )
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
          Container(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18.0,18,18,10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: Icon(FontAwesomeIcons.list,size: 50,color: Color(0xFF3BBAD5))),
                  SizedBox(width: 22,),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: Text("Report di produzione",style: TextStyle(color: Colors.white,fontSize: 18),)),
                      Flexible(child: Text("del ${_dtReport!.substring(0,10)}",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600),)),
                      Flexible(child: Text("v. ${_reportProduzione?.index.toString()}",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w400))),
                    ],
                  ),

                ],
              ),
            ),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height/21*3,
            color: Color(0xFF3BBAD5),
          ),
          Flexible(child: _createList(context)),
          // ripetiUltimoOrdineCard(),
          SizedBox(height: 100,)
        ]));}

  // List<ReportProduzioneJsonData> parseList(List responseBody) {
  //   List<ReportProduzioneJsonData> list = responseBody
  //       .map<ReportProduzioneJsonData>((f) => ReportProduzioneJsonData.fromJson(f))
  //       .toList();
  //   //ordiniamoli dal più recente al più vecchio
  //   // list.sort((a, b) => b.presId!.compareTo(a.presId!));
  //   return list;
  // }

  Widget _createList(BuildContext context) {
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._values!.isEmpty) {
      return AppUtils.emptyList(context,FontAwesomeIcons.boxArchive);
    }
    var list = ListView.builder(
        itemCount: _values!.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _values![position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }

  Widget _buildChildRow(BuildContext context, ReportProduzioneJsonData report, int position){

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              child: Card(
                color: Colors.grey[50],
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                elevation: 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Codice: ${report.codice ?? ''}"),
                        Text("Prodotto: ${report.denominazione ?? ''}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                        Text("Quantitativo: ${report.sumToDeliver}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
                        Text("Descrizione: ${report.descrizione ?? ''}")
                      ],
                    ),
                ),
                ),
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> backPressed() async {
     return true;
  }

  Future<void> readData() async {
    _listSavedReports.clear();
    WSResponse resp = await ReportProduzioneRestService.internal(context).getReportProduzioneByDate(AppUtils.toPostgresStringDate(_dtReport!));
    if(resp.success!= null && resp.success!){
      setState((){
        _listSavedReports.addAll( ReportProduzioneRestService.internal(context).parseList(resp.data!.toList()));
      });
    }
    else{
      debugPrint("errore!!");
    }
  }

  Future<void> _refresh() async {
    Fluttertoast.showToast(
        msg: "Refresh",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.lightBlueAccent[100],
        fontSize: 16.0
    );
    _listSavedReports!.clear();
    readData();
    setState(() {
      _isLoading=false;
    });
  }

  Future<void> saveReportIfNotExists() async{
    ReportProduzione? isPresent;
    int maxIndex=0;
    List<ReportProduzione> listReportProduzioneStored=[];
    ReportProduzione reportProduzione = new ReportProduzione();
    reportProduzione.hash = calculateHash(_values);
    reportProduzione.dtRiferimento=dateFormatter.parse(_dtReport!);
    if(_listSavedReports.isNotEmpty){
      isPresent =_listSavedReports.firstWhere((element)=> element.dtRiferimento == dateFormatter.parse(_dtReport!));
      if(isPresent==null){
        listReportProduzioneStored.addAll(_listSavedReports.where((element) => element.dtRiferimento == reportProduzione.dtRiferimento && element.hash == reportProduzione.hash));
        if(listReportProduzioneStored.isNotEmpty ){
          listReportProduzioneStored.forEach((element) {if(element.index! >= maxIndex){
            maxIndex=element.index!;
          }});
        }
      }
    }
    reportProduzione.index=maxIndex+1;
    String json =jsonEncode(_listData);
    reportProduzione.productsData = json;
    _reportProduzione = reportProduzione;
    if(isPresent==null && !_isFromStorico!) {
      ReportProduzioneRestService.internal(context).upsertOrdine(reportProduzione);
    }
  }




  String calculateHash(List<ReportProduzioneJsonData>? values){
    var bytes1 = utf8.encode(values.toString());
    String hash256= sha256.convert(bytes1).toString();
    String shorthash =shortHash(values!);
    return hash256;
  }

  _generatePdf() async{
    debugPrint(_reportProduzione!.toJson().toString());
    final pdfFile = await PdfReportApi.generate(_reportProduzione!,_listData!);
    PdfApi.openFile(pdfFile);
  }
}
