import 'package:bufalabuona/data/listini_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/pdf/pdf_ordine_api.dart';
import 'package:bufalabuona/screens/listini_prodotti/listini_prodotti_screen.dart';
// import 'package:bufalabuona/screens/prodotti/lov_prodotti_fragment.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../../data/cart_item_rest_service.dart';
import '../../model/cart_item.dart';
import '../../pdf/pdf_api.dart';
import '../../utils/ui_icons.dart';

class CarrelloCheckoutAdminScreen extends StatefulWidget {
  final PuntoVendita? puntoVendita;
  final Ordine? ordine;
  final List<CartItemExt>? adminValues;
  final bool readOnlyMode;
  const CarrelloCheckoutAdminScreen({Key? key,required this.ordine,required this.puntoVendita,this.adminValues,required this.readOnlyMode}) : super(key: key);

  @override
  State<CarrelloCheckoutAdminScreen> createState() => _CarrelloCheckoutAdminScreenState();
}

enum TipoPagamento { FATTURA, RICEVUTA, EXTRA }

class _CarrelloCheckoutAdminScreenState extends State<CarrelloCheckoutAdminScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final dateFormatter = new DateFormat('dd-MM-yyyy');
  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');
  PuntoVendita? _puntoVendita;
  Ordine? _ordine;
  Ordine? _ordineInviato;
  // Listino? _listino;
  List<CartItemExt> _values =[];
  List<CartItemExt> _adminValues=[];
  List<CartItemExt> _filteredValues = [];
  bool _isLoading=true;
  bool? _sendOrder = false;
  bool _isReadOnly = true;
  Map<ListinoProdottiExt,int> _listCart = Map();

  DateTime? _dtSpedizione;
  final TextEditingController _dataSpedizioneController = new TextEditingController();
  final TextEditingController _noteController = new TextEditingController();

  final RoundedLoadingButtonController _confermaController =
  RoundedLoadingButtonController();

  final RoundedLoadingButtonController _rifiutaController =
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
    _isReadOnly= this.widget.readOnlyMode;
    init();
  }

  void init() async {
    // await readData();
    // await loadPuntoVendita();
    // await loadListino();
    setState(() {
      _adminValues.addAll(this.widget.adminValues!);
      _isLoading=false;
      _dataSpedizioneController.text = dateFormatter.format(_ordine!.dtConsegna!);
      _noteController.text=_ordine!.note??'Non sono state inserite note per la consegna';
      if(_ordine!.tipoFiscaleCodice!=null){
        _tipoPagamento = (_ordine!.tipoFiscaleCodice=='FATTURA') ? TipoPagamento.FATTURA : TipoPagamento.RICEVUTA;
      }else{
      _tipoPagamento = (_puntoVendita!.flRicevuta!=null)  ? TipoPagamento.FATTURA : TipoPagamento.RICEVUTA;}
    });
  }

  // loadListino() async{
  //   WSResponse resp = await ListiniRestService.internal(context).getListinoByCatId(_puntoVendita!.catId!);
  //   if(resp.success!= null && resp.success!){
  //     setState(() {
  //       _listino=ListiniRestService.internal(context).parseList(resp.data!.toList()).first;
  //     });
  //   }
  // }

  // readData() async{
  //   if(_ordine!=null){
  //     WSResponse resp = await CartItemRestService.internal(context).getCartItemExtByOrdineId(_ordine!.id!);
  //     if(resp.success!= null && resp.success!){
  //       setState((){
  //         _values = CartItemRestService.internal(context).parseListExt(resp.data!.toList());
  //         _filteredValues.addAll(_values);
  //         _adminValues.addAll(_values);
  //       });
  //     }
  //     else{
  //       debugPrint("errore!!");
  //     }
  //     // setState(() {
  //     //   _values.clear();
  //     //   _values.addAll(_listCart.keys);
  //     //   _filteredValues=_values;
  //     // });
  //   }
  // }



  Widget buttons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if(!_isReadOnly && calcolaProdottiVendibili()>0)  Flexible(
          child: RoundedLoadingButton(
            borderRadius: 15,
            color: Colors.green,
            controller: _confermaController,
            onPressed: () {
              _submit('CONFERMA');
            },
            child: Text('CONFERMA',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          flex: 5,
        ),
        SizedBox(
          width: 20,
        ),
        if(!_isReadOnly)  Flexible(
          child: RoundedLoadingButton(
            borderRadius: 15,
            color: Colors.red,
            controller: _rifiutaController,
            onPressed: () {
              _submit('RIFIUTA');
            },
            child: const Text(
              'RIFIUTA',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
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
                ordineCard(),
                puntoVenditaCard(),
                // destinatario(),
                dataSpedizioneCard(),
                noteSpedizioneCard(),
                pagamentoCard(),
                // if(this._ordine!.statoCodice=='INVIATO')
                // TextButton.icon(
                //   onPressed: ()=>aggiungiProdotto(),
                //   label: Text("AGGIUNGI PRODOTTO"),
                //   icon: Icon(UiIcons.addIco, size: 20),
                // ),
              ],
            ),
          ),
        ),
        Flexible(
            child: Card(
          child: SingleChildScrollView(
            child: ExpansionTile(
                title: Text("Prodotti : ${calcolaProdottiVendibili()}"),
                subtitle: totaleOrdineCard(),
                children: <Widget>[
                  _createList(context),
                  SizedBox(
                    height: 10,
                  )
                ]),
          ),
        )),
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
        physics: NeverScrollableScrollPhysics(),
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
    _adminValues.addAll(this.widget.adminValues!);

    // await readData();
    // await loadPuntoVendita();
  }

  Widget _buildChildRow(BuildContext context, CartItemExt listini, int position){
    return Visibility(
      visible: listini.quantita!>0 ? true : false,
      child: Column(
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
                                Text(listini.prodDenominazione?? '',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14),),
                                Text(listini.prodDescrizione ?? ''),
                                Text("${listini.quantita} ${listini.prodUnimisDescrizione} "),
                                // Text("${listini.price.toString()} €",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16,color: Colors.black87,fontWeight: FontWeight.w700),),
                                // Text("${listini.statoCodice??''}"),
                                SizedBox(height: 5,)
                              ],
                            ),
                      ),
                        Column(
                          mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(listini.quantita.toString() ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  // Widget destinatario(){
  //   return Container(child: Card(
  //     child: Column(children: [
  //       puntoVenditaCard(),
  //       indrizzoSpedizione(),
  //     ],),
  //   ),);
  // }

  Widget ordineCard(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Ordine #${_ordine!.numero}",style: TextStyle(fontWeight: FontWeight.w600),),
          Text("del ${AppUtils.convertTimestamptzToStringDate(_ordine!.createdAt??'')?.substring(0,10)}"),
        ],),
    );}

  Widget puntoVenditaCard(){
    return Card(
    child: ListTile(
    leading: UiIcons.house,
    title:Text("${_puntoVendita?.denominazione}"),
    subtitle: Text("${_puntoVendita?.ragSociale}"))
      // child: ListTile(
      //   leading: UiIcons.house,
      //   title: Container(
      //    child: Column(
      //      crossAxisAlignment: CrossAxisAlignment.start,
      //      mainAxisAlignment: MainAxisAlignment.start,
      //      children: [
      //        // Text("Ordine numero : ${_ordine!.numero}"),
      //        // Text("del : ${AppUtils.convertTimestamptzToStringDate(_ordine!.createdAt!??'')?.substring(0,10)}"),
      //        Text("Destinatario : ${_puntoVendita!.denominazione}"),
      //        Text("p.iva : ${_puntoVendita!.partitaIva}")
      //      ],
      //    ),
      //
      //   ),
      // ),
    );
  }

  Widget indrizzoSpedizione(){
    return Container(
      width: MediaQuery.of(context).size.width,
      child: ListTile(leading: UiIcons.locationDot,
        title: Text("Invia a : ${_puntoVendita!.indirizzoConsegna?? 'NESSUN INDIRIZZO SPECIFICATO'}",style: TextStyle(fontStyle: FontStyle.italic),),
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
    _adminValues.forEach((value) {
      var price= value.price! * value.quantita!;
      total+=price;
    });
    return total.toStringAsFixed(2);
  }

  Widget totaleOrdineCard(){
    return Text("Totale Ordine ${_calcolaTotaleOrdine()}€",style: TextStyle(fontSize: 24,color:Colors.teal[800],fontWeight: FontWeight.bold),);
  }

  int calcolaProdottiVendibili(){
    int total=0;
    _adminValues.forEach((element) {
      if(element.quantita!>0){
        total+=1;
      }
    });
    return total;
  }

  _submit(String stato) async {
    bool _isOrderSended = false;
    _sendOrder = await askContinua(context,stato);
    if(_sendOrder!){
      setState(() {
        _isLoading=true;
      });
      _isOrderSended = await _createOrderAndRegisterCartItems(stato);
    }
    setState(() {
      _confermaController.reset();
      _rifiutaController.reset();
      _isLoading=false;
    });
    if(_isOrderSended){
      _goToOrdiniAdmin();}
    else{
      debugPrint("errore nell'invio admin");
    }

  }

  _goToOrdiniAdmin(){
    Map<String,dynamic>? options = new Map();
    options['utente']=AppUtils.utente;
    options['route']= 'ORDINI';
    Navigator.pushNamedAndRemoveUntil(context, '/homeAdmin', (route) => false, arguments: options);

  }

  Future<bool?> askContinua(BuildContext context,String stato) async {
    String title = "Attenzione";
    String _value = (stato =='CONFERMA') ? 'confermare' : 'rifiutare';
    String message ="Vuoi $_value l'ordine dei prodotti presenti nel carrello?";
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



  Future<bool> _createOrderAndRegisterCartItems(String statoOrdine) async {
    bool isOrderOk=false;
    bool updateProducts=false;
    bool insertProducts=false;
    List<CartItem> listCartItemsToUpdate = [];
    List<CartItem> listCartItemsToInsert = [];
    if(statoOrdine == 'CONFERMA') {
      _ordine!.statoCodice = 'CONFERMATO';
    }else if(statoOrdine == 'RIFIUTA'){
      _ordine!.statoCodice = 'RIFIUTATO';
    }
    _ordine!.total = num.parse(_calcolaTotaleOrdine());
    _ordine!.dtConsegna= postgresDateFormatter.parse(AppUtils.toPostgresStringDate(_dataSpedizioneController.text));
    _ordine!.tipoFiscaleCodice =_tipoPagamento!.name;

    var dateValue = new DateFormat("yyyy-MM-ddTHH:mm:ssZ").format(DateTime.now());
    _ordine!.modifiedAt = dateValue;

    WSResponse  resp = await OrdiniRestService.internal(context).upsertOrdine(_ordine!);
    if(resp.errors!=null){
      debugPrint(resp.errors.toString());
      _confermaController.reset();
      _rifiutaController.reset();
    }
    if(resp.success!=null && resp.success! && _adminValues.length>0) {
      _ordineInviato= resp.data!.first;
      _adminValues.forEach((element) {
          CartItem tmp = new CartItem();
          tmp.orderId = _ordineInviato!.id;
          // tmp.orderId = 1;
          tmp.prodId = element.prodId;
          tmp.quantita = element.quantita;
          tmp.statoCodice = element.statoCodice;
          tmp.note = element.note;
          if(element.id!=null){
            tmp.id =element.id;
            listCartItemsToUpdate.add(tmp);
          }else{
            listCartItemsToInsert.add(tmp);
          }
      });

      debugPrint("Da aggiornare : ${listCartItemsToUpdate.length}");
      debugPrint("Da inserire : ${listCartItemsToInsert.length}");

      ///PRATICAMENTE DEVO SPLITTARE LE DUE OPERAZIONI : INSERT LISTA NUOVI PRODOTTI
      /// UPDATE LISTA PRODOTTI ORIGINALI
      if(statoOrdine=='CONFERMA'){
        WSResponse respCartUpdate = await CartItemRestService.internal(context).upsertMultipleCartItem(listCartItemsToUpdate);
        if(respCartUpdate.success!=null && respCartUpdate.success!){
          debugPrint("abbiamo aggiornato i prodotti nel carrello");
          updateProducts=true;
         }

        if(listCartItemsToInsert.isNotEmpty){
          WSResponse respCartInsert = await CartItemRestService.internal(context).insertMultipleCartItem(listCartItemsToInsert);
          if(respCartInsert.success!=null && respCartInsert.success!){
            debugPrint("abbiamo creato inserito i nuovi prodotti e carrello");
            insertProducts=true;
          }
        }
      }
      if(statoOrdine=='RIFIUTA'){
        isOrderOk=true;
      }
    }else{
      if(statoOrdine=='RIFIUTA'){
        isOrderOk=true;
      }
    }

    if(updateProducts && (listCartItemsToInsert.isEmpty || insertProducts)){
      isOrderOk=true;
    }
    return isOrderOk;
  }

  // _createOrderAndRegisterCartItems(String statoOrdine) async {
  //   bool success=false;
  //   if(statoOrdine == 'CONFERMA') {
  //     _ordine!.statoCodice = 'CONFERMATO';
  //   }else if(statoOrdine == 'RIFIUTA'){
  //     _ordine!.statoCodice = 'RIFIUTATO';
  //   }
  //
  //   _ordine!.tipoFiscaleCodice =_tipoPagamento!.name;
  //
  //   debugPrint(_ordine!.tipoFiscaleCodice);
  //
  //   WSResponse  resp =await  OrdiniRestService.internal(context).updateOrdine(_ordine!);
  //
  //   if(resp.success!=null && resp.success!){
  //     success = true;
  //   }
  //
  //   return success;
  // }


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
                ListTile(leading: Icon(UiIcons.truckFastIco,color: Colors.black54,size: 36,),
                  title: dtSpedizione(),
                  trailing:   IconButton(icon:Icon(UiIcons.editCalendarIco,color: _isReadOnly ? Colors.grey : Colors.black87,),onPressed: _isReadOnly ? null : ()=> _chooseDtFineTrt(context)),

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
            trailing: IconButton(icon: Icon(UiIcons.editIco,color: _isReadOnly ? Colors.grey :Colors.black87,),
                onPressed: _isReadOnly ? null : ()=>_displayTextInputDialog(context,_noteController,"Inserisci note per la consegna",_ordine!.note)),
          ),
        ),
      ),
    );
  }

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
                    _textFieldController.text = defaultValue;}
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
      child: Row(
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
    );
  }

  bool _checkbox = false;
  bool _checkboxListTile = false;


  // Widget pagamento(){
  //   return Card(child: Row(crossAxisAlignment: CrossAxisAlignment.start,
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //   children: [
  //     CheckboxListTile(
  //       controlAffinity: ListTileControlAffinity.leading,
  //       title: Text('I am true'),
  //       value: _checkbox,
  //       onChanged: (value) {
  //         setState(() {
  //           _checkbox = !_checkbox;
  //         });
  //       },
  //     ),
  //   ],),);
  // }

  _generatePdf() async{
    final pdfFile = await PdfOrdineApi.generate(_ordine!,_adminValues,_puntoVendita!);
    PdfApi.openFile(pdfFile);
  }
}
