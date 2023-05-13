import 'package:bufalabuona/data/report_produzione_rest_service.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/report/dettaglio_report_screen.dart';
import 'package:bufalabuona/screens/report/storico_report_produzione_screen.dart';
import 'package:bufalabuona/utils/overlapping_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../utils/app_utils.dart';

class ReportProduzione extends StatefulWidget {
  const ReportProduzione({Key? key}) : super(key: key);

  @override
  State<ReportProduzione> createState() => _ReportProduzioneState();
}

class _ReportProduzioneState extends State<ReportProduzione> {

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
                        child: Icon(FontAwesomeIcons.cartFlatbed,size: 50,color: Color(0xFF3BBAD5))),
                    SizedBox(width: 22,),
                    Flexible(child: Text("Da questa sezione è possibile generare i report di produzione.\nOgni report contiene il totale dei prodotti in consegna per il giorno selezionato.",style: TextStyle(color: Colors.white,fontSize: 18),)),
                  ],
                ),
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/15*3,
              color: Color(0xFF3BBAD5),
            ),
            storicoReportCard(),
            reportTomorrowCard(),
            reportWithDateCard(),
            // ripetiUltimoOrdineCard(),
            SizedBox(height: 100,)
          ]),
    ));}


  Widget storicoReportCard(){
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
                // leading: OverlappingIncons(iconBase: Icon(FontAwesomeIcons.boxArchive,color: Colors.black54,size: 36,),iconOver: Icon(FontAwesomeIcons.list,color: Colors.lightBlueAccent,size: 22,),size: 36,),
                leading: Icon(FontAwesomeIcons.boxArchive,color: Colors.black54,size: 36,),
                title: TextFormField(
                    maxLines: 2,
                    controller: _storicoReport,
                    decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
                      labelText: "Storico Report",
                      enabled: false,
                    )),
                trailing: IconButton(icon: Icon(Icons.chevron_right,color: Colors.black54,),
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
              leading: OverlappingIncons(iconBase: Icon(FontAwesomeIcons.list,color: Colors.black54,size: 32,),iconOver: Icon(FontAwesomeIcons.bolt,color: Colors.orange,),size: 36,),
                // leading: Icon(FontAwesomeIcons.list,color: Colors.black54,size: 36,),
                title: TextFormField(
                    maxLines: 2,
                    controller: _generaReportTomorrow,
                    decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
                      labelText: "Genera Report",
                      enabled: false,
                    )),
                trailing: IconButton(icon: Icon(Icons.chevron_right,color: Colors.black54,),
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
                leading: OverlappingIncons(iconBase: Icon(FontAwesomeIcons.list,color: Colors.black54,size: 32,),iconOver: Icon(FontAwesomeIcons.solidCalendarDays,color: Colors.lightBlueAccent,),size: 36,),
                // leading: Icon(FontAwesomeIcons.list,color: Colors.black54,size: 36,),
                title: TextFormField(
                    maxLines: 2,
                    controller: _generaReportWithDate,
                    decoration: InputDecoration(
                      disabledBorder: InputBorder.none,
                      labelText: "Genera Report",
                      enabled: false,
                    )),
                trailing: IconButton(icon: Icon(Icons.chevron_right,color: Colors.black54,),
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
        builder: (context) =>new StoricoReportProduzioneScreen()));
  }

  Future<void> _goReport(String dtReport) async{
    WSResponse resp =await ReportProduzioneRestService.internal(context).getReportProduzione(dtReport.substring(0,10));

    if(resp.data!=null){
      _goToDetail(resp.data!,dtReport.substring(0,10));
    }
    else{
      resp;
      debugPrint("STOCAZZO");
      AppUtils.errorSnackBar(_scaffoldKey, "Nessun report disponibile");
    }
  }

  void _goToDetail(List data,String dtReport){
     Navigator.push(context, MaterialPageRoute(builder: (context)=> DettaglioReportScreen(data: data,dtReport: dtReport,isFromStorico: false,)));
  }

  //SELECT DATE

  Widget dtInizioTrattamento() {
    return new Row(children: <Widget>[
      new IconButton(
        icon: Icon(FontAwesomeIcons.calendarCheck),
        onPressed: () {},
      ),
      new Expanded(
        child: Container(
          padding: EdgeInsets.all(10.0),
          decoration: BoxDecoration(),
          child: TextFormField(
            enabled: false,
            decoration: new InputDecoration(
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
      _dtReportTextController!.text =
      date != null ? dateFormatter.format(date) : '';
    });
    if(_dtReportTextController.text.isNotEmpty){
    _goReport(_dtReportTextController.text);}
  }
}
