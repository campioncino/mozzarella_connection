import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/listini_prodotti_rest_service.dart';
import 'package:bufalabuona/data/listini_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/data/prodotti_rest_service.dart';
import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/listini_prodotti/listini_prodotti_screen.dart';
// import 'package:bufalabuona/screens/prodotti/lov_prodotti_fragment.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class CarrelloDettaglioAdminScreen extends StatefulWidget {
  final PuntoVendita? puntoVendita;
  final Ordine? ordine;
  const CarrelloDettaglioAdminScreen({Key? key,required this.ordine,required this.puntoVendita}) : super(key: key);

  @override
  State<CarrelloDettaglioAdminScreen> createState() => _CarrelloDettaglioAdminScreenState();
}

enum TipoPagamento { fattura, ricevuta }

class _CarrelloDettaglioAdminScreenState extends State<CarrelloDettaglioAdminScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final dateFormatter = new DateFormat('dd-MM-yyyy');
  PuntoVendita? _puntoVendita;
  Ordine? _ordine;
  Listino? _listino;
  List<CartItemExt> _values =[];
  List<CartItemExt> _adminValues=[];
  List<CartItemExt> _filteredValues = [];
  bool _isLoading=true;
  bool? _sendOrder = false;
  Map<ListinoProdottiExt,int> _listCart = Map();

  DateTime? _dtSpedizione;
  final TextEditingController _dataSpedizioneController = new TextEditingController();
  final TextEditingController _noteController = new TextEditingController();

  final RoundedLoadingButtonController _confermaController =
  RoundedLoadingButtonController();

  final RoundedLoadingButtonController _rifiutaontroller =
  RoundedLoadingButtonController();

  String? alertDialogValueText;
  TipoPagamento? _tipoPagamento;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ordine=this.widget.ordine;
    _puntoVendita=this.widget.puntoVendita;
    _filteredValues.clear();

    init();
  }

  void init() async {
    await readData();
    await loadPuntoVendita();
    await loadListino();
    setState(() {
      _isLoading=false;
      _dataSpedizioneController.text = dateFormatter.format(_ordine!.dtConsegna!);
      _noteController.text=_ordine!.note??'Non sono state inserite note per la consegna';
      _tipoPagamento = (_puntoVendita!.flRicevuta!=null)  ? TipoPagamento.fattura : TipoPagamento.ricevuta;
    });
  }

  loadPuntoVendita() async{
    _puntoVendita =await PuntiVenditaRestService.internal(context).getPuntoVendita(_ordine!.pvenditaId!);
  }

  loadListino() async{
    WSResponse resp = await ListiniRestService.internal(context).getListinoByCatId(_puntoVendita!.catId!);
    if(resp.success!= null && resp.success!){
      setState(() {
        _listino=ListiniRestService.internal(context).parseList(resp.data!.toList()).first;
      });
    }
  }

  readData() async{
    if(_ordine!=null){
      WSResponse resp = await CartItemRestService.internal(context).getCartItemExtByOrdineId(_ordine!.id!);
      if(resp.success!= null && resp.success!){
        setState((){
          _values = CartItemRestService.internal(context).parseListExt(resp.data!.toList());
          _filteredValues.addAll(_values);
          _adminValues.addAll(_values);
        });
      }
      else{
        debugPrint("errore!!");
      }
      // setState(() {
      //   _values.clear();
      //   _values.addAll(_listCart.keys);
      //   _filteredValues=_values;
      // });
    }
  }



  Widget buttons() {
    var confermaBtn = RoundedLoadingButton(
      borderRadius: 15,
      color: Colors.green,
      controller: _confermaController,
      onPressed: () {
        _submit('CONFERMA');
      },
      child: Text('CONFERMA',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );

    var rifiutaBtn = RoundedLoadingButton(
      borderRadius: 15,
      color: Colors.red,
      controller: _rifiutaontroller,
      onPressed: () {
        _submit('RIFIUTA');
      },
      child: const Text(
        'RIFIUTA',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if(this._ordine!.statoCodice=='INVIATO')  Flexible(
          child: confermaBtn,
          flex: 5,
        ),
        SizedBox(
          width: 20,
        ),
        if(this._ordine!.statoCodice=='INVIATO')  Flexible(
          child: rifiutaBtn,
          flex: 3,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dettaglio Ordine'),
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: backPressed,
            child: stackWidget()),
    bottomNavigationBar: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 30),
      child: buttons(),
    ),
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
                destinatario(),
                dataSpedizioneCard(),
                noteSpedizioneCard(),
                if(this._ordine!.statoCodice=='INVIATO')
                TextButton.icon(
                  onPressed: ()=>aggiungiProdotto(),
                  label: Text("AGGIUNGI PRODOTTO"),
                  icon: Icon(Icons.add, size: 20),
                ),
              ],
            ),
          ),
        ),

        Flexible(child: _createList(context)),
      ],
    ));
  }

  Widget _createList(BuildContext context) {
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._adminValues.isEmpty) {
      return AppUtils.emptyList(context,FontAwesomeIcons.slash);
    }
    var list = ListView.builder(
        itemCount: _adminValues.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _adminValues[position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }

  Future<void> _refresh() async{
    _filteredValues.clear();
    _values.clear();
    _adminValues.clear();
    await readData();
    await loadPuntoVendita();
  }

  Widget _buildChildRow(BuildContext context, CartItemExt listini, int position){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                elevation: 1.0,
                child: InkWell(
                  // onTap: ()=> _goToEdit(listini),
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
                                  Text(listini.prodDenominazione?? '',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                  Text(listini.prodDescrizione ?? ''),
                                  Text("${listini.quantita} ${listini.prodUnimisDescrizione} "),
                                  Text("${listini.price.toString()} €",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16,color: Colors.black87,fontWeight: FontWeight.w700),),
                                  Text("${listini.statoCodice??''}"),
                                ],
                              ),
                        ),
                          Column(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(icon: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(width: 4, color: Colors.white)),
                                  child: (listini.quantita!=null && listini.quantita!>1) ? Icon(FontAwesomeIcons.minus,size: 20,color: Colors.black54):Icon(FontAwesomeIcons.trash, size: 22, color: Colors.red,)),
                                    onPressed: (){setState(() {
                                    if(listini.quantita!>0){listini.quantita = listini.quantita!-1;}
                                  });}),
                              SizedBox(width: 10,),
                              Text(listini.quantita.toString() ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
                              SizedBox(width: 10,),
                              IconButton(icon: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[800],
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(width: 5, color: Colors.teal[800]!)),child: Icon(FontAwesomeIcons.plus,size: 20,color: Colors.white70,)),onPressed: (){setState(() {
                                        if(listini.quantita!=null){
                                          listini.quantita = listini.quantita!+1;
                                        }
                                      });},)
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget destinatario(){
    return Container(child: Card(
      child: Column(children: [
        puntoVenditaCard(),
        indrizzoSpedizione(),
      ],),
    ),);
  }



  Widget puntoVenditaCard(){
    return ListTile(
      leading: Icon(FontAwesomeIcons.house),
      title: Container(
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         mainAxisAlignment: MainAxisAlignment.start,
         children: [
           Text("Odine numero : ${_ordine!.numero}"),
           Text("del : ${AppUtils.convertTimestamptzToStringDate(_ordine!.createdAt!??'')?.substring(0,10)}"),
           Text("Destinatario : ${_puntoVendita!.denominazione}"),
           Text("p.iva : ${_puntoVendita!.partitaIva}")
         ],
       ),

      ),
    );
  }

  Widget indrizzoSpedizione(){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListTile(leading: Icon(FontAwesomeIcons.locationDot,color: Colors.black54),
        title: Text("Invia a : ${_puntoVendita!.indirizzoConsegna?? 'NESSUN INDIRIZZO SPECIFICATO'}",style: TextStyle(fontStyle: FontStyle.italic),),
        // trailing: IconButton(icon: Icon(FontAwesomeIcons.pencil),onPressed: (){},),
      ),
    );
  }

  Future<bool> backPressed() async {
      Navigator.pop(context, this._listCart);
      return true;
    }

  bool checkElementInCart(ListinoProdottiExt item){
    bool isPresent=false;
    _listCart.forEach((key, value) {if(key.prodId==item.prodId){
      isPresent=true;
    }});
    return isPresent;
  }

  addElementToList(CartItemExt item){
      setState(() {
        item.quantita!+1;
      });
  }

  removeElementToList(CartItemExt item){
      if(item.quantita!>0){
        setState(() {
          item.quantita!-1;
        });
      }
  }

  String _calcolaTotaleOrdine(){
     num total=0;
    _values.forEach((value) {
      var price= value.price! * value.quantita!;
      total+=price;
    });
    return total.toString();
  }


  _submit(String stato) async {
    bool _isOrderSended = false;
    _sendOrder = await askContinua(context);
    if(_sendOrder!){
      setState(() {
        _isLoading=true;
      });
      _isOrderSended = await _createOrderAndRegisterCartItems(stato);
    }
    setState(() {
      _confermaController.reset();
      _rifiutaontroller.reset();
      _isLoading=false;
    });
    if(_isOrderSended){
      _goToOrdiniAdmin();}
    else{
      debugPrint("errore nell'invio orcodio");
    }

  }

  _goToOrdiniAdmin(){
    Map<String,dynamic>? options = new Map();
    options['utente']=AppUtils.utente;
    options['route']= 'ORDINI';
    Navigator.pushNamedAndRemoveUntil(context, '/homeAdmin', (route) => false, arguments: options);

  }

  Future<bool?> askContinua(BuildContext context) async {
    String title = "Attenzione";
    String message ="Vuoi confermare l'ordine dei prodotti presenti nel carrello?";
    bool? ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
          title: Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text(message),
          actions: <Widget>[
            TextButton(
                child: Text("ANNuLLA"),
                onPressed: () {
                  Navigator.pop(context,false);
                }),
            TextButton(
                child: Text("OK",style: TextStyle(fontSize: 22),),
                onPressed: () {
                  Navigator.pop(context,true);
                }),
          ]
      ),
    );
    return ok!;
  }

  _createOrderAndRegisterCartItems(String statoOrdine) async {
    bool success=false;
    if(statoOrdine == 'CONFERMA') {
      _ordine!.statoCodice = 'CONFERMATO';
    }else if(statoOrdine == 'RIFIUTA'){
      _ordine!.statoCodice = 'RIFIUTATO';
    }

    WSResponse  resp =await  OrdiniRestService.internal(context).updateOrdine(_ordine!);

    if(resp.success!=null && resp.success!){
      success = true;
    }

    return success;
  }

  aggiungiProdotto() async{
    List<ListinoProdottiExt> list=[];

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ListiniProdottiScreen(listino: _listino,lovMode: true,))
    ).then((value){
      if(value!=null){
        ListinoProdottiExt lp = value as ListinoProdottiExt;
        CartItemExt cartItemTmp = CartItemExt.fromJson(lp.toJson());
        cartItemTmp.quantita=1;
        debugPrint(cartItemTmp.toString());
        setState(() {
          _adminValues.add(cartItemTmp);
        });

      }
    });

  }

  Widget dataSpedizioneCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 2.0,right: 2.0, bottom: 2,top:2),
      child: Card(
        child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: RichText(text: TextSpan(children: <TextSpan>[
                      TextSpan(text: "Attenzione: ",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                      TextSpan(text: "l'ordine del cliente è stato effettuato alle ore: ",style: TextStyle(color: Colors.black54)),
                      TextSpan(text: "${AppUtils.convertTimestamptzToStringDate(_ordine!.createdAt!)}",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal[800])),
                      TextSpan(text: "\nPuoi modificare la data di consegna",style: TextStyle(color: Colors.black54)),
                    ]
                    ))),
                ListTile(leading: Icon(FontAwesomeIcons.truckFast,color: Colors.black54,size: 36,),
                  title: dtSpedizione(),
                  trailing:   IconButton(icon:Icon(Icons.edit_calendar,color: Colors.black87,),onPressed:()=> _chooseDtFineTrt(context)),

                ),
              ],
            )),
      ),
    );
  }

  Widget dtSpedizione() {
    return  Row(children: <Widget>[
      Expanded(
        child: Container(
          decoration: BoxDecoration(),
          child: TextFormField(
            enabled: false,
            decoration:  const InputDecoration(
              hintText: "data consegna",
              labelText:"data consegna",
              disabledBorder: InputBorder.none,
              labelStyle: TextStyle(color: Colors.black54),
              enabled: false,
            ),
            controller: _dataSpedizioneController,
            style: TextStyle(color: Colors.black87,fontSize: 16,fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ]);
  }

  Future _chooseDtFineTrt(BuildContext context) async {
    DateTime initialDate=DateTime.now();
    DateTime lastDate = DateTime(2100);
    DateTime firstDate = DateTime.now();

    var result = await showDatePicker(
      context: context,
      initialDate: initialDate,
      lastDate: lastDate,
      firstDate: firstDate,
    );
    _dtSpedizioneSelected(result);
  }

  _dtSpedizioneSelected(DateTime? date) {
    setState(() {
      _dtSpedizione = date;
      _dataSpedizioneController.text = date != null ? dateFormatter.format(date) : '';
      // this._trattamentoTO!.tratDtFine =
      // _dtFineTrtTextController!.text.isNotEmpty ? _dtFineTrtTextController!.text : null;
    });
  }

  Widget noteSpedizioneCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 2.0,right: 2.0, top: 2,bottom:2),
      child: Card(
        child: Container(
          // color:Colors.white70,
          width: MediaQuery.of(context).size.width,
          child: ListTile(leading: Icon(FontAwesomeIcons.noteSticky,color: Colors.black54,size: 36,),
            title: TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                  disabledBorder: InputBorder.none,
                  labelText: "Note per la consegna",
                  hintText: 'Aggiungi qui le note per la spedizione'),
              enabled: false,
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black87),
            ),
            // title: Text("Invia a : ${_puntoVendita!.indirizzo?? 'NESSUN INDIRIZZO SPECIFICATO'}",style: TextStyle(fontStyle: FontStyle.italic),),
            trailing: IconButton(icon: Icon(Icons.edit,color: Colors.black87,),
                onPressed: ()=>_displayTextInputDialog(context,_noteController,"Inserisci note per la consegna")),
          ),
        ),
      ),
    );
  }

  Future<void> _displayTextInputDialog(BuildContext context, TextEditingController _textFieldController, String title) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title:  Text(title),
            content: TextFormField(
              onChanged: (value) {
                setState(() {
                  alertDialogValueText = value;
                });
              },
              controller: _textFieldController,
              decoration:
              const InputDecoration(hintText: ""),
            ),
            actions: <Widget>[
              TextButton(

                child: const Text('Annulla'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              TextButton(

                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    _textFieldController.text = alertDialogValueText??'';
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Widget pagamentoCard(){
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          RadioListTile<TipoPagamento>(
            title: const Text('Fattura'),
            value: TipoPagamento.fattura,
            groupValue: _tipoPagamento,
            onChanged: (TipoPagamento? value) {
              setState(() {
                _tipoPagamento = value;
              });
            },
          ),
          RadioListTile<TipoPagamento>(
            title: const Text('Ricevuta Fiscale'),
            value: TipoPagamento.ricevuta,
            groupValue: _tipoPagamento,
            onChanged: (TipoPagamento? value) {
              setState(() {
                _tipoPagamento = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget totaleOrdineCard(){
    return Text("Totale Ordine ${_calcolaTotaleOrdine()}€",style: TextStyle(fontSize: 24,color:Colors.teal[800],fontWeight: FontWeight.bold),);
  }

}
