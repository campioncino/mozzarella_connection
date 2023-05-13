import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class ConfirmedOrderScreen extends StatefulWidget {

  final Map<String?, dynamic>? options;
  const ConfirmedOrderScreen({Key? key,required this.options}) : super(key: key);

  @override
  State<ConfirmedOrderScreen> createState() => _ConfirmedOrderScreenState();
}

class _ConfirmedOrderScreenState extends State<ConfirmedOrderScreen> {

  final RoundedLoadingButtonController _submitController = RoundedLoadingButtonController();
  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');
  final dateFormatter = new DateFormat('dd-MM-yyyy');

  Ordine? _confirmedOrder;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _confirmedOrder = this.widget.options?['ordine'];
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        child: Scaffold(
          floatingActionButton : RoundedLoadingButton(onPressed: _goHome,
              borderRadius: 15,
              color: Colors.amberAccent,
              controller: _submitController,child: Text("Torna agli acquisti",style: TextStyle(fontSize: 22,color: Colors.black),)),
          body: Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Align(alignment:Alignment.bottomLeft,child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(FontAwesomeIcons.check,size: 66,color: Colors.white,),
                    Text("Caro ${AppUtils.utente.name},",style: TextStyle(color: Colors.white,fontSize: 22),),
                    Text("Grazie per aver effettuato l'ordine!",style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w800),),
                  ],
                ),
              )),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/7*3,
              color: Color(0xFF3BBAD5),
            ),
            _confirmedOrder!=null ? dettaglioOrdine() : Container()],
        ),
      ],
    ),));
  }

  Widget dettaglioOrdine(){
    return Container(child: Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text("Dettaglio Ordine:", style: TextStyle(fontWeight: FontWeight.w700,color: Colors.black54,fontSize: 20),),
        Text("Ordine numero: ${_confirmedOrder!.numero}", style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black54,fontSize: 18)),
          Text("Data dell'ordine: ${AppUtils.convertTimestamptzToStringDate(_confirmedOrder!.createdAt ??'')}",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black54,fontSize: 18)),
        Text("Data della consegna: ${dateFormatter.format(_confirmedOrder!.dtConsegna!)} ",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.black54,fontSize: 18)),
          SizedBox(height: 6,),
          Text("Totale: ${_confirmedOrder!.total} €",style: TextStyle(fontWeight: FontWeight.w700,color: Color(0xFF3BBAD5),fontSize: 21)),
        SizedBox(height: 10,),
        RichText(text: TextSpan(text:"Abbiamo ricevuto la richiesta per il tuo ordine, controlliamo la disponibilità della merce e nel più breve tempo possibile procederemo alla conferma dell'ordine",style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black54,fontSize: 18))),
        SizedBox(height: 5,),RichText(text: TextSpan(text: "Ti invieremo una notifica non appena il tuo ordine passerà dallo stato ",children: <TextSpan>[TextSpan(text:"INVIATO",style: TextStyle(fontWeight: FontWeight.bold)),TextSpan(text:" allo stato "),TextSpan(text:"CONFERMATO",style: TextStyle(fontWeight: FontWeight.bold))],style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black54,fontSize: 18))),
    //   SizedBox(height: 25,),Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 38.0),
    //     child: ElevatedButton.icon(
    //     onPressed: () {},
    //     icon: Icon(
    //       Icons.edit,
    //       size: 24.0,
    //     ),
    //     label: Text("Aggiungi note relative all'ordine"), // <-- Text
    // ),
    //   ),
        ],),
    ),);
  }

  _goHome(){
    Map<String,dynamic>? options = new Map();
    options['utente']=AppUtils.utente;
    options['puntoVendita']=AppUtils.puntoVendita;
    options['route']= 'PRODOTTI';
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false, arguments: options);
  }
}
