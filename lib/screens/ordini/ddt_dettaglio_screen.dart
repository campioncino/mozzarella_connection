import 'dart:convert';

import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/listini_rest_service.dart';
import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/data/report_confezionamento_rest_service.dart';
import 'package:bufalabuona/model/cart.dart';
import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/ordine_ext.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/report_confezionamento.dart';
import 'package:bufalabuona/model/report_ddt.dart';
import 'package:bufalabuona/model/report_ddt_prodotto.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/pdf/pdf_ddt_api.dart';
import 'package:bufalabuona/screens/carrello/carello_checkout_admin_screen.dart';
import 'package:bufalabuona/screens/listini_prodotti/listini_prodotti_screen.dart';
// import 'package:bufalabuona/screens/prodotti/lov_prodotti_fragment.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../model/cart_item.dart';
import '../../pdf/pdf_api.dart';
import '../../pdf/pdf_report_api.dart';
import '../../utils/ui_icons.dart';

class DdtDettaglioScreen extends StatefulWidget {
  final OrdineExt? ordine;
  const DdtDettaglioScreen({Key? key,required this.ordine}) : super(key: key);

  @override
  State<DdtDettaglioScreen> createState() => _DdtDettaglioScreenState();
}


class _DdtDettaglioScreenState extends State<DdtDettaglioScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final dateFormatter = new DateFormat('dd-MM-yyyy');
  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');
  PuntoVendita? _puntoVendita;
  OrdineExt? _ordine;
  Listino? _listino;
  List<ReportConfezionamento> _values =[];
  List<ReportConfezionamento> _adminValues=[];
  // List<ReportConfezionamento> _filteredValues = [];
  bool _isLoading=true;
  bool _isReadOnly = true;
  Map<ListinoProdottiExt,int> _listCart = Map();
  List? _listData;

  ReportDdt? _reportDdt;
  List<ReportDdtProtto>? _prodottiList;

  DateTime? _dataTrasporto;

  final TextEditingController _dataSpedizioneController = new TextEditingController();
  final TextEditingController _noteController = new TextEditingController();
  final TextEditingController _dataTrasportoTextController = new TextEditingController();

  final RoundedLoadingButtonController _submitController = RoundedLoadingButtonController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ordine=this.widget.ordine;
    _isReadOnly =_ordine!.statoCodice=='INVIATO' ? false : true;
    init();
  }

  void init() async {
    await readData();
    setState(() {
      _isLoading=false;
      _dataSpedizioneController.text = dateFormatter.format(_ordine!.dtConsegna!);
      _noteController.text=_ordine!.note??'Non sono state inserite note per la consegna';
if(_values.isNotEmpty){
      _reportDdt = ReportConfezionamentoRestService(context).parseDDTList(jsonDecode(_values.first.productsData!)).first;
      var prodotti = _reportDdt!.ddtInfo!['prodotti'];
      _prodottiList = prodotti.map<ReportDdtProtto>((f) => ReportDdtProtto.fromJson(f)).toList();
      _puntoVendita =  PuntoVendita.fromDBMap(_reportDdt!.ddtInfo!['cliente'][0]);}
    });
  }


  readData() async{
    if(_ordine!=null){
      WSResponse resp = await ReportConfezionamentoRestService.internal(context).getDDTOrdine(_ordine!.numero!);
      if(resp.success!= null && resp.success!){
        setState((){
          _values = ReportConfezionamentoRestService.internal(context).parseList(resp.data!.toList());
          // _filteredValues.addAll(_values);
          _adminValues.addAll(_values);
        });
      }
      else{
        debugPrint("errore!!");
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dettaglio DDT'),
          actions: [FloatingActionButton(
              backgroundColor: Colors.white70,
              elevation: 0.0,
              child: UiIcons.pdfRounded,
              // backgroundColor: const Color(0xFFE57373),
              onPressed:() async =>await _generatePdf())],
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: backPressed,
            child: stackWidget()),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        // floatingActionButton: TextButton(onPressed: (){},child: Text("Stampa PDF"),),
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                ordineCard(),
                // destinatario(),
              ],
            ),
          ),
        ),

        Flexible(child: _createList(context)),
        SizedBox(height: 100,)
      ],
    ));
  }

  Widget _createList(BuildContext context) {
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._adminValues.isEmpty) {
      return AppUtils.emptyList(context,UiIcons.emptyIco);
    }
    var list = ListView.builder(
      shrinkWrap: true,

        itemCount: _adminValues.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _adminValues[position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }

  Future<void> _refresh() async{
    // _filteredValues.clear();
    _values.clear();
    _adminValues.clear();
    await readData();
  }

  Widget _buildChildRow(BuildContext context, ReportConfezionamento ddt, int position){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Container(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Row(
                    children: [
                    Expanded(
                      child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ddtNumeroCard(ddt),
                             if(ddt.note!=null && ddt.note!.isNotEmpty) Text("Note DDT: ${ddt.note}"),
                              Container(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Data Trasporto ${AppUtils.convertTimestamptzToStringDate(ddt.dataTrasporto.toString()??'').substring(0,10) ??''}"),
                                    IconButton(onPressed: ()=>_changeDtTrasporto(), icon: UiIcons.pencil)
                                  ],
                                ),
                              ),
                              dettaglioOrdine(_reportDdt!)
                            ],
                          ),
                    ),
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


Widget dettaglioOrdine(ReportDdt ddt){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment:MainAxisAlignment.start ,
      mainAxisSize: MainAxisSize.min,
      children: [

      Text("Causale: ${ddt.causale??''}"),
      Text("Note Ordine: ${ddt.noteOrdine??''}"),
      Text("Costo Spedizione: ${ddt.costoSpedizione??''}"),
      Text("Fatturazione: ${ddt.tipoFatturazione??''}"),
      Text("Vettore: ${ddt.vettoreTrasporto??''}"),
      Text("Indirizzo Consegna: ${ddt.indirizzoConsegnaOrdine??''}"),
      Text("TOTALE : ${ddt.totaleOrdine}"),
      divider("Info Cliente"),
      cliente(_puntoVendita!),
      divider("Prodotti"),
      Flexible(child: prodotti(_prodottiList!))
    ],);
}


  Widget ordineCard(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text("Ordine #${_ordine!.numero}",style: TextStyle(fontWeight: FontWeight.w600),),
        Text("del ${AppUtils.convertTimestamptzToStringDate(_ordine!.createdAt ??'')?.substring(0,10)}"),
      ],),
    );}

  Widget ddtNumeroCard(ReportConfezionamento ddt){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("DDT #${ddt.numeroDdt}",style: TextStyle(fontWeight: FontWeight.w600),),
        Text("creato ${AppUtils.convertTimestamptzToStringDate(ddt.createdAt??'').substring(0,19) ??''} "),
      ],);}

  Future<bool> backPressed() async {
      Navigator.pop(context, this._listCart);
      return true;
  }

  Widget cliente(PuntoVendita pv){
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text("Ragione Sociale : ${pv.ragSociale}"),
      Text("Denominazione : ${pv.denominazione}"),
      Text("P.Iva : ${pv.partitaIva}"),
      Text("Indirizzo : ${pv.indirizzo}"),
      Text("ID Fatturazione : ${pv.idFatturazione}")
    ],);
  }

  Widget prodotti(List<ReportDdtProtto> prodottiList){
    return ListView.builder(
        shrinkWrap: true,
          itemCount: prodottiList.length,
          itemBuilder: (context, position) {
          return _buildItem(context, prodottiList[position], position);
    });
  }

  Widget _buildItem(BuildContext context, ReportDdtProtto prodotto, int position){
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text("${prodotto.descrizione??''}"),
          Row(
            children: [
            Text("${prodotto.quantita??''}"),
            Text("${prodotto.unimisCodice??''}"),
            SizedBox(width: 5,),
            Expanded(child:  Text("${prodotto.denominazione??''}"),),
          ],),
          Text("Prezzo unitario : ${prodotto.price??''}"),
          Divider()
        ]);
  }

  Widget divider(String text){
    return Row(children: <Widget>[
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 0.0, right: 20.0),
              child: Divider(
                height: 36,
              )),
        ),
        Text(text),
        Expanded(
          child: new Container(
              margin: const EdgeInsets.only(left: 20.0, right: 0.0),
              child: Divider(
                height: 36,
              )),
        ),
      ]);
  }

  _changeDtTrasporto() async{
    bool? check = await askChangeDataTrasportoDDT(context);
    if(check!=null && check){
      debugPrint("Change Date");
      await _chooseDataTrasporto(context,_ordine!);
    }
  }

  Future<bool?> askChangeDataTrasportoDDT(BuildContext context) async {
    String title = "Attenzione";
    String message ="Vuoi cambiare la DATA di TRASPORTO del DDT?";
    bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
          title: Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text(message),
          actions: <Widget>[
            TextButton(
                child: Text("ANNULLA"),
                onPressed: () {
                  Navigator.pop(context,false);
                }),
            TextButton(
                child: Text("OK",),
                onPressed: () {
                  Navigator.pop(context,true);
                }),
          ]
      ),
    );
    return ok!;
  }


  //SELECT DATE
  Future _chooseDataTrasporto(BuildContext context,OrdineExt ordine) async {
    DateTime lastDate = new DateTime(2100);
    DateTime firstDate = new DateTime(1970);
    DateTime initialDate = new DateTime.now();
    var result = await showDatePicker(
        fieldLabelText: "DATA TRASPORTO",
        fieldHintText: "SCEGLI DATA TRASPORTO",
        helpText: "SCEGLI DATA TRASPORTO",
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate);
    _dtInzioSelected(result,ordine);
  }

  _dtInzioSelected(DateTime? date,OrdineExt ordine) async{
    setState(() {
      _dataTrasporto = date;
      _dataTrasportoTextController.text =
      date != null ? dateFormatter.format(date) : '';
    });
    if(_dataTrasportoTextController.text.isNotEmpty){
      ///TODO generate ddt
      debugPrint("sparaflashami");
      _adminValues[0].dataTrasporto = dateFormatter.parse(_dataTrasportoTextController.text!);
      await _updateReport( _adminValues[0]);
    }
  }

  _updateReport(ReportConfezionamento reportNew) async{
    setState(() {
      _isLoading=true;
    });
    WSResponse response = await ReportConfezionamentoRestService.internal(context).updateDataTrasporto(reportNew);
    if(response.success==null || response.success==false){
      AppUtils.errorSnackBar(_scaffoldKey, "Non è stato possibile aggiornare la Data Trasporto del DDT");
    }
    setState(() {
      AppUtils.successSnackBar(_scaffoldKey, "Data Trasporto Aggiornata con successo!\nRICORDATI DI STAMPARE IL NUOVO DDT");
      _isLoading=false;
    });
  }

  _generatePdf() async{
    final pdfFile = await PdfDdtApi.generate(_values.first!,_reportDdt!,_puntoVendita!,_prodottiList!);
    PdfApi.openFile(pdfFile);
  }




}
