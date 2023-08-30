import 'dart:convert';

import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/report_ddt.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/carrello/carello_dettaglio_admin_screen.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:bufalabuona/utils/overlapping_icons.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';

import '../../data/report_confezionamento_rest_service.dart';
import '../../model/ordine_ext.dart';
import '../../model/report_confezionamento.dart';
import '../../utils/ui_icons.dart';
import 'ddt_dettaglio_screen.dart';


class ListOrdiniAdminScreen extends StatefulWidget {
  const ListOrdiniAdminScreen({Key? key}) : super(key: key);

  @override
  State<ListOrdiniAdminScreen> createState() => _ListOrdiniAdminScreenState();
}

class _ListOrdiniAdminScreenState extends State<ListOrdiniAdminScreen> {
  final dateFormatter = new DateFormat('dd-MM-yyyy');
  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');

  Categoria? _cat;
  bool _isLoading = true;
  bool _withConfermato = false;

  // PuntoVendita? _puntoVendita;

  final GlobalKey<ScaffoldState> _refreshKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController _searchController = new TextEditingController();

  List<OrdineExt>? _values ;
  List<OrdineExt> _filteredValues = [];

  final TextEditingController _dataTrasportoTextController=new TextEditingController();
  DateTime? _dataTrasporto;

  _ListOrdiniAdminScreenState() {
    _searchController.addListener(() {
      handleSearch(_searchController.text);
    });
  }

  void handleSearch(String text) {
    setState(() {
      if (text.isEmpty) {
        _filteredValues.clear();
        debugPrint(_values.toString());
        _filteredValues.addAll(_values!);
      } else {
        List<OrdineExt> list = _values!.where((v) {
          return v.createdAt!.contains(text.toUpperCase())
              || v.statoCodice!.contains(text.toUpperCase())
              || v.pvenditaDenominazione!.toUpperCase().contains(text.toUpperCase());
        }).toList();
        _filteredValues.clear();
        _filteredValues.addAll(list);
      }
    });
  }

  Future<void> readData() async {
    _filteredValues.clear();
    WSResponse resp = await OrdiniRestService.internal(context).getListOrdiniInConsegna();
    if(resp.success!= null && resp.success!){
      setState((){
        _values = OrdiniRestService.internal(context).parseListExt(resp.data!.toList());
        _filteredValues.addAll(_values!);
      });
    }
    else{
      debugPrint("errore!!");
    }
  }


  List<Categoria> parseList(List responseBody) {
    List<Categoria> list = responseBody
        .map<Categoria>((f) => Categoria.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _filteredValues.clear();
    init();
  }

  void init() async{
    await readData();
    setState(() {
      _isLoading=false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: WillPopScope(
              onWillPop: null,
              child: stackWidget()),
      ),
    );
  }

  Widget stackWidget() {
    List<Widget> listWidgets = [];

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
      children: [
        _buildSearchBar(context),
        SizedBox(height: 20),
        Flexible(child: _createList(context)),
      ],
    ));
  }

  Widget _createList(BuildContext context) {
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._filteredValues.isEmpty) {
      return AppUtils.emptyList(context,UiIcons.truckFastIco);
    }

    var list= GroupedListView<dynamic, String>(
      elements: _filteredValues,
      groupBy: (element) => element.dtConsegna.toString().substring(0,10),
      itemComparator: (item2, item1) => item1.pvenditaDenominazione.compareTo(item2.pvenditaDenominazione),

      groupSeparatorBuilder: (String groupByValue) => Container(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 2),
        child: Text("IN CONSEGNA IL : $groupByValue",style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 20),),
      ),height: 32,),
      itemBuilder: (context, element) {
        return  Padding(
          padding: const EdgeInsets.only(bottom: 18.0),
          child: Row(
            children: [
              Flexible(
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                  elevation: 3.0,
                  child: InkWell(
                    onTap: ()=> _goToDetail(element),
                    child: ListTile(
                      trailing: UiIcons.chevronRight,
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Ordine #${element.numero} "),
                              Text("effettuato: ${AppUtils.convertTimestamptzToStringDate(element.createdAt??'')}",
                                // style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                              ),
                            ],
                          ),
                          // Text(utentiList![index].toJson().toString()),


                          // Text(utentiList![index].toJson().toString()),
                          Text(element.pvenditaDenominazione??'',style: TextStyle(fontWeight: FontWeight.w800,fontSize: 16)),
                          Text("Totale ordine: ${element.total} €"),
                          Text("Stato: ${element.statoCodice?? ''}",style: TextStyle(fontWeight: FontWeight.w600)),
                          if(element.statoCodice=='CONFERMATO') Text("confermato il: ${AppUtils.convertTimestamptzToStringDate(element.modifiedAt??'')}"),
                         // Text("Consegna spedizione: ${AppUtils.formPostgresStringDate(element.dtConsegna?.toString().substring(0,10)?? '')}"),
                          ddt(element),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );

      },
      // itemComparator: (item1, item2) => item1['dataConsegna'].compareTo(item2['dataConsegna']), // optional
      useStickyGroupSeparators: true, // optional
      // floatingHeader: true, // optional
      order: GroupedListOrder.DESC, // optional
    );

    // var list = ListView.builder(
    //     itemCount: _filteredValues.length,
    //     itemBuilder: (context, position) {
    //       return _buildChildRow(context, _filteredValues[position], position);
    //     });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }


  void _goToDetail(OrdineExt ordine) {

    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new DdtDettaglioScreen(ordine: ordine,))).then((value) => _refresh());
  }


  Future<void> _refresh() async {
    Fluttertoast.showToast(
        msg: "Refresh",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.redAccent,
        fontSize: 16.0
    );
    _values!.clear();
     readData();
    setState(() {
      _isLoading=false;
    });
  }

  Widget _buildSearchBar(BuildContext context) {
    TextField searchField = TextField(
      style: TextStyle(fontSize: 20.0,
      ),
      controller: _searchController,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText:"Cerca per Nome",
          suffixIcon: IconButton(
              icon: UiIcons.close, onPressed: () => onSearchButtonClear())),
    );

    return Card(
        elevation: 5.0,
        margin: EdgeInsets.all(10.0),
        child:  Padding(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: searchField,
        ));
  }

  Future onSearchButtonClear() async {
    setState(() {
      //This is not working. Exception - invalid text selection: TextSelection(baseOffset: 2, extentOffset: 2, affinity: TextAffinity.upstream, isDirectional: false)
      //ref https://github.com/flutter/flutter/issues/17647
      //_searchController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchController.clear());
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  Widget ddt(OrdineExt ordine){
    if(ordine.statoCodice=='CONFERMATO'){
      if(ordine.numeroDDT != null && ordine.numeroDDT!.isNotEmpty){
        debugPrint("numero ${ordine.numero} - ${AppUtils.calculateHash(ordine)}");
       return  Column(
         children: [
           Text("DDT :${ordine.numeroDDT}"),
           // Text("HASH : ${AppUtils.calculateHash(ordine)}")

         ],
       );
      }else{
       return generaDDTButton(ordine);
      }
    }else{
     return Text("DDT NON DISPONIBILE");
    }

  }

  Widget generaDDTButton(OrdineExt ordine){
     return TextButton.icon(
         onPressed: ()=>_chooseDataTrasporto(context,ordine),
         icon: OverlappingIncons(size: 24,iconOver: Icon(UiIcons.emptyFileIco,size: 24,color: Colors.black45,),iconBase: Container(child: Center(child: Text("DDT",style: TextStyle(fontWeight: FontWeight.w900,fontSize: 10,color: Colors.deepOrange))),width: 36,height: 36,),fullOverlapping: true,),
         label: Text('Genera DDT',style: TextStyle(fontWeight: FontWeight.w800,color: Colors.deepOrange),));
  }

  Future<String?> _generaDDT(OrdineExt ordine) async{
    String? numeroDDT;
    setState(() {
      _isLoading=true;
    });
    WSResponse resp =await ReportConfezionamentoRestService.internal(context).generateDDTOrdine(ordine.numero);

    if(resp.data!=null){
      List<ReportDdt> data =await ReportConfezionamentoRestService.internal(context).parseDDTList(resp.data!);
      numeroDDT = data[0].ddtNumero.toString();
      await saveReportIfNotExists(ordine, data, numeroDDT);
    }
    else{
      resp;
      AppUtils.errorSnackBar(_scaffoldKey, "Errore nella generazione");
    }
    setState(() {
      ordine.numeroDDT=numeroDDT;
      _isLoading=false;

    });
  }

  Future<void> saveReportIfNotExists(OrdineExt ordine,List data, String numeroDDT) async{
    setState(() {
      _isLoading=true;
    });
    ReportConfezionamento report = new ReportConfezionamento();
    report.hash = AppUtils.calculateHash(ordine);
    report.dataTrasporto= postgresDateFormatter.parse(AppUtils.toPostgresStringDate(_dataTrasportoTextController.text));
    String json =jsonEncode(data);
    report.productsData = json;
    report.numeroOrdine = ordine.numero;
    report.numeroDdt = numeroDDT;
    WSResponse response = await ReportConfezionamentoRestService.internal(context).upsertReport(report);
    if(response.success==null || response.success==false){
      AppUtils.errorSnackBar(_scaffoldKey, "Non è stato possibile salvare il DDT");
    }
    setState(() {
      _isLoading=false;
    });
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

  _dtInzioSelected(DateTime? date,OrdineExt ordine) {
    setState(() {
      _dataTrasporto = date;
      _dataTrasportoTextController.text =
      date != null ? dateFormatter.format(date) : '';
    });
    if(_dataTrasportoTextController.text.isNotEmpty){
      ///TODO generate ddt
      debugPrint("sparaflashami");
      _generaDDT(ordine);
      // _goReport(_dataTrasportoTextController.text);
    }
  }
}
