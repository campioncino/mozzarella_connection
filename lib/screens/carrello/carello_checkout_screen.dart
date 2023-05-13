import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/model/cart_item.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../clienti/home.dart';

class CarelloCheckoutScreen extends ConsumerStatefulWidget {
  final PuntoVendita? puntoVendita;
  final Map<ListinoProdottiExt,int>? listCart;

  const CarelloCheckoutScreen({Key? key, @required this.puntoVendita, @required this.listCart}) : super(key: key);

  @override
  ConsumerState<CarelloCheckoutScreen> createState() => _CarelloCheckoutScreenState();
}

class _CarelloCheckoutScreenState extends ConsumerState<CarelloCheckoutScreen> {

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final globalKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _submitController = RoundedLoadingButtonController();


  PuntoVendita? _puntoVendita;
  Map<ListinoProdottiExt,int>? _listCart;

  TextEditingController _indirizzoController = new TextEditingController();
  TextEditingController _dataSpedizioneController = new TextEditingController();
  TextEditingController _noteController = new TextEditingController();

  final dateFormatter = new DateFormat('dd-MM-yyyy');
  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');

  DateTime? _dtSpedizione;

  bool _isLoading=true;
  bool? _sendOrder = false;

  Ordine? _ordineInviato;

  bool _indirizzoEnabled=false;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listCart=this.widget.listCart;
    _puntoVendita=this.widget.puntoVendita;
    _isLoading=false;
    init();
  }

  void init() async {
    setState(() {
      _dtSpedizione = DateTime.now().add((Duration(days:2)));
      
      _indirizzoController.text = _puntoVendita!.indirizzoConsegna ?? 'INSERIRE INDIRIZZO DI CONSEGNA';
      _dataSpedizioneController.text = dateFormatter.format(_dtSpedizione!);
      _isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
        key: _scaffoldKey,
        child: Scaffold(
        appBar: AppBar(
          title: Text('Concludi Ordine'),
          // actions: [IconButton(onPressed: _svuotaCarello, icon:  Icon(Icons.remove_shopping_cart,size: 33,))],
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
        onWillPop: backPressed,
        child: stackWidget()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: checkoutButton()));
  }

  Widget checkoutButton(){
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        children: [
          Text("Totale ${_calcolaTotaleOrdine()}€",style: TextStyle(fontSize: 24,color:Colors.teal[800],fontWeight: FontWeight.bold),),
          SizedBox(width: 40,),
          Expanded(
            child: RoundedLoadingButton(onPressed: _submit,
                borderRadius: 15,
                color: Colors.amberAccent,
                controller: _submitController,child: Text("Checkout",style: TextStyle(fontSize: 22,color: Colors.black),)),
          )
        ],
      ),
    );
  }

  Future<bool> backPressed() async {
    Navigator.pop(context, this._listCart);
    return true;
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
            indirizzoSpedizioneCard(),
            dataSpedizioneCard(),
            noteSpedizioneCard(),
            prodottiRiepilogoCard(),
            SizedBox(height: 100,)
          ]),
    ));}

  _submit() async {
    if(_indirizzoController.text.isEmpty && _puntoVendita!.indirizzo==null){
      showMessage("Inserire l'indirizzo di consegna");
      _submitController.reset();
      return;
    }
    if(_listCart!=null && _listCart!.isNotEmpty) {
      bool _isOrderSended = false;
      _sendOrder = await askContinua(context);
      if (_sendOrder!) {
        setState(() {
          _isLoading = true;
        });
        _isOrderSended = await _createOrderAndRegisterCartItems();
      }

      setState(() {
        _isLoading = false;
        if(!_sendOrder!){
          _submitController.reset();
        }else{
          _submitController.success();}
      });
      if (_isOrderSended) {
        // _goToOrdini();
        _goToConfirmed();
      }
      else {
        debugPrint("errore nell'invio");
      }
    }else{
      showMessage("Il tuo ordine pieno di NULLA è stato accettato!\nControlla dovrebbe già esserti stato consgnato!");
      _submitController.reset();
    }
  }


  Future<bool?> askContinua(BuildContext context) async {
    String title = "Attenzione";
    String message ="Vuoi effettuare l'ordine dei prodotti presenti nel carrello?";
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
                child: Text("OK",style: TextStyle(fontSize: 22),),
                onPressed: () {
                  Navigator.pop(context,true);
                }),
          ]
      ),
    );
    return ok!;
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    _scaffoldKey.currentState!.showSnackBar(snackbar);
  }

  Future<bool> _createOrderAndRegisterCartItems() async {
    bool isOrderOk=false;
    Ordine ordine = new Ordine();
    if(_indirizzoController.text.isNotEmpty){
      ordine.indirizzoConsegna = _indirizzoController.text;
    }else{
      ordine.indirizzoConsegna = _puntoVendita!.indirizzo!;}
    ordine.total = num.parse(_calcolaTotaleOrdine());
    ordine.utenteId = AppUtils.utente.profileId!;
    ordine.statoCodice = "INVIATO";
    ordine.pvenditaId = _puntoVendita!.id;
    ordine.note = "note ordine";
    ordine.dtConsegna = postgresDateFormatter.parse(AppUtils.toPostgresStringDate(_dataSpedizioneController.text));


    WSResponse  resp = await OrdiniRestService.internal(context).upsertOrdine(ordine);
    if(resp.errors!=null){
      debugPrint(resp.errors.toString());
      _submitController.reset();
    }
    if(resp.success!=null && resp.success! && _listCart!.length>0) {
      _ordineInviato= resp.data!.first;
      List<CartItem> listCartItems = [];
      _listCart!.forEach((key, value) {
        if (value > 0) {
          CartItem tmp = new CartItem();
          tmp.orderId = _ordineInviato!.id;
          // tmp.orderId = 1;
          tmp.prodId = key.sku;
          tmp.quantita = value;
          tmp.statoCodice = "INVIATO";
          tmp.note = "inviato dal cliente";
          listCartItems.add(tmp);
        }
      });


      WSResponse respCart = await CartItemRestService.internal(context)
          .upsertMultipleCartItem(listCartItems);
      if(respCart.success!=null && respCart.success!){
        debugPrint("abbiamo creato ordine e carrello");
        isOrderOk=true;
      }
    }

    return isOrderOk;
  }

  _goToConfirmed(){
    Map<String,dynamic>? options = new Map();
    options['utente']=AppUtils.utente;
    options['puntoVendita']=_puntoVendita;
    options['ordine']=_ordineInviato;
    ref.read(counterStateProvider.notifier).state=0;
    AppUtils.clearCartItems();
    Navigator.pushNamedAndRemoveUntil(context, '/confirmedOrder', (route) => false, arguments: options);
  }

  String _calcolaTotaleOrdine(){
    num total=0;
    _listCart!.forEach((key, value) {
      var price= key.price! * value;
      total+=price;
    });
    return total.toString();
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
                    TextSpan(text: "la consegna della merce  nel giorno successivo è garantita solo per gli ordini effettuati entro le ",style: TextStyle(color: Colors.black54)),
                  TextSpan(text: "18:00.",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                    TextSpan(text: "\nIn tutti gli altri casi, la merce verrà consegnata nel prima data utile",style: TextStyle(color: Colors.black54)),


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
            decoration: new InputDecoration(
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

  Widget prodottiRiepilogoCard(){
    List<String> prodotti =[];
    _listCart!.forEach((key, value) {return prodotti.add(key.prodDenominazione!);});
    return Padding(
      padding: const EdgeInsets.only(left: 2.0,right: 2.0, top: 2),
      child: Card(
        child: Container(
          // color: Color(0xFF3BBAD5),
          // color:Colors.lightBlue[300],
          width: MediaQuery.of(context).size.width,
          child: ListTile(leading: Icon(FontAwesomeIcons.basketShopping,color: Colors.black54,size: 36,),
            title: Column(children: [
              Text(prodotti.join("\n"))
            ],),
            // title: Text("Invia a : ${_puntoVendita!.indirizzo?? 'NESSUN INDIRIZZO SPECIFICATO'}",style: TextStyle(fontStyle: FontStyle.italic),),
            trailing: IconButton(icon: Icon(Icons.chevron_right,color: Colors.black54,),onPressed: (){
              Navigator.pop(context);
            },),
          ),
        ),
      ),
    );
  }

  Widget indirizzoSpedizioneCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 2.0,right: 2.0, top: 2,bottom:2),
      child: Card(
        child: Container(
          // color: Color(0xFF3BBAD5),
          // color:Colors.lightBlue[300],
          width: MediaQuery.of(context).size.width,
          child: ListTile(leading: Icon(FontAwesomeIcons.mapLocationDot,color: Colors.black54,size: 36,),
            title: TextFormField(
              maxLines: 2,
              controller: _indirizzoController,
              decoration: InputDecoration(
                  disabledBorder: InputBorder.none,
                  labelText: "indirizzo consegna",
                  hintText: _puntoVendita!.indirizzo ?? 'NESSUN INDIRIZZO SPECIFICATO'),
              enabled: false,
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15,color: Colors.black54),
            ),
            // title: Text("Invia a : ${_puntoVendita!.indirizzo?? 'NESSUN INDIRIZZO SPECIFICATO'}",style: TextStyle(fontStyle: FontStyle.italic),),
            trailing: IconButton(icon: Icon(Icons.edit_location_alt_outlined,color: Colors.black54,),
                onPressed: ()=>_displayTextInputDialog(context,_indirizzoController,"Inserisci indirizzo per la consegna",_puntoVendita!.indirizzoConsegna)
            )
          ),
          ),
        ),
    );
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
                      onPressed: ()=>_displayTextInputDialog(context,_noteController,"Inserisci note per la consegna",null)),
          ),
        ),
      ),
    );
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

  String? alertDialogValueText;

  Future<void> _displayTextInputDialog(BuildContext context, TextEditingController _textFieldController, String title, String? defaultValue) async {
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
                    if(defaultValue!=null){
                    _textFieldController.text=defaultValue;}
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
}
