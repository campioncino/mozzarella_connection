import 'package:bufalabuona/data/report_produzione_rest_service.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/report_confezionamento/storico_report_confezionamento_screen.dart';
import 'package:bufalabuona/screens/report_produzione/dettaglio_report_screen.dart';
import 'package:bufalabuona/screens/report_produzione/storico_report_produzione_screen.dart';
import 'package:bufalabuona/utils/overlapping_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../data/report_confezionamento_rest_service.dart';
import '../../utils/app_utils.dart';
import '../../utils/ui_icons.dart';

class ReportConfezionamentoScreen extends StatefulWidget {
  const ReportConfezionamentoScreen({Key? key}) : super(key: key);

  @override
  State<ReportConfezionamentoScreen> createState() => _ReportConfezionamentoScreenState();
}

class _ReportConfezionamentoScreenState extends State<ReportConfezionamentoScreen> {

  bool _isLoading=true;

  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');
  final dateFormatter = new DateFormat('dd-MM-yyyy');

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final globalKey = GlobalKey<ScaffoldState>();

  final TextEditingController _storicoReport = new TextEditingController(text:"Visualizza lo storico dei report");
  final TextEditingController _generaReportTomorrow = new TextEditingController(text:"Visualizza il report di produzione per domani");
  final TextEditingController _generaReportWithDate = new TextEditingController(text:"Visualizza un nuovo report scegliendo la data");

  DateTime? dtReport;
  final TextEditingController _dtReportTextController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoading=false;
  }


  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
        key: _scaffoldKey,
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: stackWidget()));
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
    return Expanded(child: SingleChildScrollView(
      child: Column(
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
                        child: UiIcons.cartReport),
                    SizedBox(width: 22,),
                    Flexible(child: Text("Da questa sezione è possibile visualizzare i report relativi al confezionamento per gli ordini.\nIl report contiene il totale dei prodotti in consegna per il giorno selezionato.",style: TextStyle(color: Colors.white,fontSize: 16),)),
                  ],
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/15*3,
              color: Color(0xFF3BBAD5),
            ),
            storicoProduzioniCard(),
            reportTomorrowCard(),
            reportWithDateCard(),
            // ripetiUltimoOrdineCard(),
            SizedBox(height: 100,)
          ]),
    ));}


  Widget storicoProduzioniCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 4.0,right: 4.0, top: 8,bottom:0),
      child: InkWell(
        onTap: _goStorico,
        child: Card(
          child: Container(
            // color: Color(0xFF3BBAD5),
            // color:Colors.lightBlue[300],
            width: MediaQuery.of(context).size.width,
            child: ListTile(
                leading: UiIcons.boxArchive,
                title: TextFormField(
                    style: TextStyle(color:Colors.black45,fontWeight: FontWeight.w500),
                    maxLines: 2,
                    controller: _storicoReport,
                    decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
                      labelText: "Storico Report",
                      labelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w800,color: Colors.black54),
                      enabled: false,
                    )),
                trailing: IconButton(icon: UiIcons.chevronRight,
                    onPressed: _goStorico
                )
            ),
          ),
        ),
      ),
    );
  }

  Widget reportTomorrowCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 4.0,right: 4.0, top: 8,bottom:0),
      child: InkWell(
        onTap:_generateTomorrowReport,
        child: Card(
          child: Container(
            // color: Color(0xFF3BBAD5),
            // color:Colors.lightBlue[300],
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              leading: OverlappingIncons(iconBase: UiIcons.listReport,iconOver: UiIcons.bolt,size: 36,),
                // leading: Icon(UiIcons.listIco,color: Colors.black54,size: 36,),
                title: TextFormField(
                    style: TextStyle(color:Colors.black45,fontWeight: FontWeight.w500),
                    maxLines: 2,
                    controller: _generaReportTomorrow,
                    decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
                      labelText: "Genera Report",
                      labelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w800,color: Colors.black54),
                      enabled: false,
                    )),
                trailing: IconButton(icon: UiIcons.chevronRight,
                    onPressed:()=> _generateTomorrowReport()
                )
            ),
          ),
        ),
      ),
    );
  }

  Widget reportWithDateCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 4.0,right: 4.0, top: 8,bottom:0),
      child: InkWell(
        onTap:()=> _chooseDtInizioTrt(context),
        child: Card(
          child: Container(
            // color: Color(0xFF3BBAD5),
            // color:Colors.lightBlue[300],
            width: MediaQuery.of(context).size.width,
            child: ListTile(
                leading: OverlappingIncons(iconBase: UiIcons.listReport,iconOver: UiIcons.calendarDays,size: 36,),
                // leading: Icon(UiIcons.listIco,color: Colors.black54,size: 36,),
                title: TextFormField(
                    style: TextStyle(color:Colors.black45,fontWeight: FontWeight.w500),
                    maxLines: 2,
                    controller: _generaReportWithDate,
                    decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
                      labelText: "Genera Report",
                      labelStyle: TextStyle(fontSize: 24,fontWeight: FontWeight.w800,color: Colors.black54),
                      enabled: false,
                    )),
                trailing: IconButton(icon: UiIcons.chevronRight,
                    onPressed:()=> _chooseDtInizioTrt(context)
                )
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _generateTomorrowReport() async {
    DateTime tomorrow = DateTime.now().add(new Duration(days: 1));
    _dtReportTextController.text = dateFormatter.format(tomorrow);
    // _dtReportTextController.text = '21-04-2023';
    await _goReport(_dtReportTextController.text);
  }


  void _goStorico(){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>new StoricoReportConfezionamentoScreen()));
  }

  Future<void> _goReport(String dtReport) async{
    WSResponse resp =await ReportConfezionamentoRestService.internal(context).getReportConfezionamento(dtReport.substring(0,10));

    if(resp.data!=null){
      _goToDetail(resp.data!,dtReport.substring(0,10));
    }
    else{
      resp;
      AppUtils.errorSnackBar(_scaffoldKey, "Nessun report disponibile");
    }
  }

  void _goToDetail(List data,String dtReport){
     Navigator.push(context, MaterialPageRoute(builder: (context)=> DettaglioReportScreen(data: data,dtReport: dtReport,isFromStorico: false,)));
  }

  //SELECT DATE

  Widget dtInizioTrattamento() {
    return  Row(children: <Widget>[
      IconButton(
        icon: UiIcons.calendarCheck,
        onPressed: () {},
      ),
       Expanded(
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(),
          child: TextFormField(
            enabled: false,
            decoration:  InputDecoration(
              hintText: 'seleziona data',
              labelText:'data report',
              enabled: false,
            ),
            controller: _dtReportTextController,
          ),
        ),
      ),
    ]);
  }

  Future _chooseDtInizioTrt(BuildContext context) async {
    DateTime lastDate = new DateTime(2100);
    DateTime firstDate = new DateTime(1970);
    DateTime initialDate = new DateTime.now();
    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate);
    _dtInzioSelected(result);
  }

  _dtInzioSelected(DateTime? date) {
    setState(() {
      dtReport = date;
      _dtReportTextController.text =
      date != null ? dateFormatter.format(date) : '';
    });
    if(_dtReportTextController.text.isNotEmpty){
    _goReport(_dtReportTextController.text);}
  }
}
