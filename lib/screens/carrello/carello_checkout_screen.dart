import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/model/cart_item.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:bufalabuona/utils/ui_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../home_clienti/home.dart';

class CarelloCheckoutScreen extends ConsumerStatefulWidget {
  final PuntoVendita? puntoVendita;
  final Map<ListinoProdottiExt,num>? listCart;

  const CarelloCheckoutScreen({Key? key, @required this.puntoVendita, @required this.listCart}) : super(key: key);

  @override
  ConsumerState<CarelloCheckoutScreen> createState() => _CarelloCheckoutScreenState();
}

enum TipoPagamento { FATTURA, RICEVUTA, EXTRA }

class _CarelloCheckoutScreenState extends ConsumerState<CarelloCheckoutScreen> {

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final globalKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _submitController = RoundedLoadingButtonController();


  PuntoVendita? _puntoVendita;
  Map<ListinoProdottiExt,num>? _listCart;

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
  TipoPagamento? _tipoPagamento;
  bool _isReadOnly=false;

  bool fattura=false;
  bool ricevuta=false;

  List<String> _listIndirizziConsegna=[];

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
      ricevuta=_puntoVendita!.flRicevuta ?? false;
      fattura = _puntoVendita!.flFattura ?? false;
      if(fattura && !ricevuta){
        _tipoPagamento = TipoPagamento.FATTURA;
      }else if(!fattura && ricevuta){
        _tipoPagamento = TipoPagamento.RICEVUTA;
      }
      _dtSpedizione = DateTime.now().add((Duration(days:2)));
      _indirizzoController.text = _puntoVendita!.indirizzoConsegna ?? 'INSERIRE INDIRIZZO DI CONSEGNA';
      initDataSpedizione();
      initIndirizziConsegna();
      // _dataSpedizioneController.text = dateFormatter.format(_dtSpedizione!);
      _isLoading=false;
    });
  }

  void initDataSpedizione() {
    if (_dtSpedizione!.isBefore(DateTime.now())) {
        _dtSpedizioneSelected(DateTime.now().add(const Duration(days: 1)));
    }else{
    setState(() {
        _dataSpedizioneController.text =
            dateFormatter.format(_dtSpedizione!);
    });
    }
  }

  void initIndirizziConsegna(){
    if(_puntoVendita!.indirizzoConsegna!=null){
      _listIndirizziConsegna.add(_puntoVendita!.indirizzoConsegna!);
    }
    if(_puntoVendita!.indirizzo!=null){
      _listIndirizziConsegna.add(_puntoVendita!.indirizzo!);
    }
    _listIndirizziConsegna.add('Ritiro presso punto vendita');
  }

  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
        key: _scaffoldKey,
        child: Scaffold(
        appBar: AppBar(
          title: Text('Concludi Ordine'),
          // actions: [IconButton(onPressed: _svuotaCarello, icon:  UiIcons.removeShoppingCart)],
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
                controller: _submitController,
                child: Text("Checkout",style: TextStyle(fontSize: 22,color: Colors.black),)),
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
            pagamentoCard(),
            SizedBox(height: 100,)
          ]),
    ));}

  _submit() async {
    if(_indirizzoController.text.isEmpty && _puntoVendita!.indirizzo==null){
      showMessage("Inserire l'indirizzo di consegna");
      _submitController.reset();
      return;
    }

    if(_tipoPagamento==null){
      showMessage("Selezionare la modalità di pagamento");
      _submitController.reset();
      return;
    }

    if(_dataSpedizioneController.text==null || _dataSpedizioneController.text.isEmpty){
      showMessage("Selezionare la data di consegna");
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
    ordine.note = _noteController.text ?? '';
    ordine.dtConsegna = postgresDateFormatter.parse(AppUtils.toPostgresStringDate(_dataSpedizioneController.text));
    ordine.tipoFiscaleCodice = _tipoPagamento!.name;

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
          .insertMultipleCartItem(listCartItems);
      if(respCart.success!=null && respCart.success!){
        debugPrint("abbiamo creato ordine e carrello");
        isOrderOk=true;
      }else{
        debugPrint(respCart.errors.toString());
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
    return total.toStringAsFixed(2);
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
                ListTile(leading: Icon(UiIcons.truckFastIco,color: Colors.black54,size: 36,),
                  title: dtSpedizione(),
                  trailing:   IconButton(icon:Icon(UiIcons.editCalendarIco,color: Colors.black87,),onPressed:()=> _chooseDtFineTrt(context)),

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
          child: ListTile(leading: Icon(UiIcons.basketShoppingIco,color: Colors.black54,size: 36,),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Elenco dei Prodotti"),
              Text(prodotti.join("\n"))
            ],),
            // title: Text("Invia a : ${_puntoVendita!.indirizzo?? 'NESSUN INDIRIZZO SPECIFICATO'}",style: TextStyle(fontStyle: FontStyle.italic),),
            trailing: IconButton(icon: UiIcons.chevronRight,onPressed: (){
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
          child: ListTile(leading: UiIcons.mapLocationDot,
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
            trailing: IconButton(icon: UiIcons.editLocation,
                // onPressed: ()=>_displayTextInputDialog(context,_indirizzoController,"Inserisci indirizzo per la consegna",_puntoVendita!.indirizzoConsegna)
                onPressed:()=> showModalBottomSheet(context:context,
                    builder: (BuildContext context){
                      return SizedBox(height: 500,child: Column(children: [
                        SizedBox(height: 3,),
                        Text("Seleziona l'indirizzo di consegna dei prodotti",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                        SingleChildScrollView(child:createRadioListIndirizzi()),
                        MaterialButton(onPressed: ()=>_displayTextInputDialog(context,_indirizzoController,"Inserisci indirizzo per la consegna",_puntoVendita!.indirizzoConsegna,_listIndirizziConsegna), child: Text('Aggiungi nuovo indirizo'))
                      ],));
                } ),
            )
          ),
          ),
        ),
    );
  }


  setSelectedIndirizzo(String address) {
    setState(() {
      _indirizzoController.text = address;
    });
  }

   Widget createRadioListIndirizzi() {
    List<Widget> widgets = [];
    for (String indirizzo in _listIndirizziConsegna) {
      widgets.add(
        RadioListTile(
          value: indirizzo,
          groupValue: null,
          title: Text(indirizzo),
          onChanged: (value) {
            setSelectedIndirizzo(value.toString());
            Navigator.pop(context);
          },
          activeColor: Colors.green,
        ),
      );
    }
    return new Column(children: widgets);
  }


  Widget noteSpedizioneCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 2.0,right: 2.0, top: 2,bottom:2),
      child: Card(
        child: Container(
          // color:Colors.white70,
          width: MediaQuery.of(context).size.width,
          child: ListTile(leading: Icon(UiIcons.noteStickyIco,color: Colors.black54,size: 36,),
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
            trailing: IconButton(icon: Icon(UiIcons.editIco,color: Colors.black87,),
                      onPressed: ()=>_displayTextInputDialog(context,_noteController,"Inserisci note per la consegna",null,null)),
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

  Future<void> _displayTextInputDialog(BuildContext context, TextEditingController _textFieldController, String title, String? defaultValue, List? listValue) async {
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
                    if(alertDialogValueText!=null && listValue!=null){
                      listValue.add(alertDialogValueText);
                      Navigator.pop(context);
                    }
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }

  Widget pagamentoCard(){
   if(_puntoVendita!.flFattura!=null && _puntoVendita!.flFattura! && _puntoVendita!.flRicevuta!=null && _puntoVendita!.flRicevuta!){
     return Padding(
       padding: const EdgeInsets.all(2.0),
       child: Card(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.start,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Padding(
               padding: const EdgeInsets.fromLTRB(14,14,10,4),
               child: Text("tipo di documento fiscale",style: TextStyle(fontSize: 14,color: Colors.black54)),
             ),
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: <Widget>[

                 Expanded(
                   flex: 1,
                   child: RadioListTile<TipoPagamento>(
                     title: const Text('Fattura'),
                     value: TipoPagamento.FATTURA,
                     groupValue: _tipoPagamento,
                     onChanged: _isReadOnly ?null :(TipoPagamento? value) {
                       setState(() {
                         _tipoPagamento = value;
                       });
                     },
                   ),
                 ),
                 Expanded(
                   flex: 1,
                   child: RadioListTile<TipoPagamento>(
                     title: const Text('Ricevuta'),
                     value: TipoPagamento.RICEVUTA,
                     groupValue: _tipoPagamento,
                     onChanged: _isReadOnly ?null :(TipoPagamento? value) {
                       setState(() {
                         _tipoPagamento = value;
                       });
                     },
                   ),
                 ),
               ],
             ),
           ],
         ),
       ),
     ) ;
   }else{
   return Container();}
  }


}
