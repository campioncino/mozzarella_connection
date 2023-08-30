import 'dart:convert';

import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/data/stato_ordine_rest_service.dart';
import 'package:bufalabuona/model/cart_item.dart';
import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/ui_icons.dart';

class OrdineDettaglioScreen extends StatefulWidget {
  final PuntoVendita? puntoVendita;
  final Ordine? ordine;
  const OrdineDettaglioScreen({Key? key,required this.ordine,required this.puntoVendita}) : super(key: key);

  @override
  State<OrdineDettaglioScreen> createState() => _OrdineDettaglioScreenState();
}

class _OrdineDettaglioScreenState extends State<OrdineDettaglioScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  PuntoVendita? _puntoVendita;
  Ordine? _ordine;

  List<CartItemExt> _values =[];
  List<CartItemExt> _filteredValues = [];
  bool _isLoading=true;
  bool? _sendOrder = false;
   Map<ListinoProdottiExt,int> _listCart = Map();

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
    setState(() {
      _isLoading=false;
    });
  }

  readData() async{
    if(_ordine!=null){
      WSResponse resp = await CartItemRestService.internal(context).getCartItemExtByOrdineId(_ordine!.id!);
      if(resp.success!= null && resp.success!){
        setState((){
          _values = CartItemRestService.internal(context).parseListExt(resp.data!.toList());
          _filteredValues.addAll(_values);
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
          title: Text('Dettaglio Ordine'),
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: backPressed,
            child: stackWidget()),
    //     floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    // floatingActionButton :FloatingActionButton.extended(onPressed: _submit,
    //   label:  Text("Conferma",style: TextStyle(fontSize: 22,)),
    // isExtended: true,backgroundColor:
    // Colors.amberAccent,)
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
    return  Stack(children: listWidgets);
  }

  Widget body() {
    return Expanded(child: Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if(_puntoVendita!=null)riepilogoOrdineCard(),
        totaleOrdineCard(),
        Flexible(child: _createList(context)),

      ],
    ));
  }

  Widget _createList(BuildContext context) {
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._values.isEmpty) {
      return AppUtils.emptyList(context,UiIcons.emptyIco);
    }
    var list = ListView.builder(
        itemCount: _values.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _values[position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }

  Future<void> _refresh() async{
    _filteredValues.clear();
    _values.clear();
    readData();
  }

  // Widget _buildChildRow(BuildContext context, CartItemExt listini, int position){
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     mainAxisAlignment: MainAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Flexible(
  //             flex: 8,
  //             child: Card(
  //               margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
  //               elevation: 1.0,
  //               child: InkWell(
  //                 // onTap: ()=> _goToEdit(listini),
  //                 child: Container(
  //                   width: double.infinity,
  //                   child: Padding(
  //                     padding: const EdgeInsets.fromLTRB( 15.0,10,15,10),
  //                     child: Row(
  //                       children: [
  //                         Text(listini.quantita.toString(),style: TextStyle(fontSize: 30),),
  //                         Text(" x ",style: TextStyle(fontSize: 18),),
  //                       SizedBox(width: 20,),
  //                       Expanded(
  //                         child: Column(
  //                               crossAxisAlignment: CrossAxisAlignment.start,
  //                               children: [
  //                                 Text(listini.prodDenominazione?? '',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
  //                                 // Text(listini.prodDescrizione ?? ''),
  //                                 Text("${listini.price.toString()} € / ${listini.prodUnimisCodice}",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16),),
  //                                 Text("${listini.status??''}"),
  //                               ],
  //                             ),
  //                       ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             flex: 2,
  //             child: Padding(
  //               padding: const EdgeInsets.fromLTRB(0,10,7,10),
  //               child: FittedBox(
  //                   fit: BoxFit.fitWidth,
  //                   child: Center(
  //                     child: ConstrainedBox(
  //                         constraints: const BoxConstraints(
  //                           minWidth: 70,
  //                           minHeight: 70,
  //                           maxWidth: 150,
  //                           maxHeight: 150,
  //                         ),
  //                         child: Text("€ ${_calcolaParzialeOrdine(listini)}",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20,color: Colors.teal[800],fontWeight: FontWeight.w700) ,)),
  //                   )),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ],
  //   );
  // }

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
                                Text("${listini.price.toString()} €",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 22,color: Colors.green),),
                                Text("${listini.status??''}"),
                              ],
                            ),
                          ),
                          // Row(
                          //   mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                          //   crossAxisAlignment: CrossAxisAlignment.center,
                          //   children: [
                          //     IconButton(icon: Container(
                          //         decoration: BoxDecoration(
                          //             borderRadius: BorderRadius.circular(100),
                          //             border: Border.all(width: 2, color: Colors.green)),
                          //         child: Icon(UiIcons.minusIco,size: 20,color: Colors.green,)),onPressed: ()=>removeElementToList(listini),),
                          //     SizedBox(width: 10,),
                          //     Text(_listCart[listini].toString() ,style: TextStyle(fontSize: 18),),
                          //     SizedBox(width: 10,),
                          //     IconButton(icon: Container(
                          //         decoration: BoxDecoration(
                          //             borderRadius: BorderRadius.circular(100),
                          //             border: Border.all(width: 2, color: Colors.green)),child: UiIcons.plus),onPressed: ()=>addElementToList(listini),)
                          //
                          //   ],
                          // ),
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



  String _calcolaParzialeOrdine(CartItemExt listino){
    return (listino.quantita! * double.parse(listino.price!.toStringAsFixed(2))).toStringAsFixed(2);
  }


  Widget riepilogoOrdineCard(){
    return Container(
        color: Colors.teal[50],
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child:  Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Data ordine: ${AppUtils.convertTimestamptzToStringDate(_ordine!.createdAt??'').substring(0,10) ??'' }",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14),),
              Text("Numero ordine #: ${_ordine!.numero }",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14),),
              Text("Stato Ordine : ${_ordine!.statoCodice}",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14),),
              Text("Indirizzo consegna : ${_ordine!.indirizzoConsegna ?? 'NESSUN INDIRIZZO SPECIFICATO'}",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 14),),
            ],
          ),
        )

    );
  }

  Widget totaleOrdineCard(){
    return Container(
      // color: Colors.teal[50],
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Text("Totale Ordine ${_calcolaTotaleOrdine()}€",style: TextStyle(fontSize: 24,color:Colors.red[900],fontWeight: FontWeight.bold),),
      )

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

  addElementToList(ListinoProdottiExt item){
    if(checkElementInCart(item)){
      int val = _listCart[item]!;
      val++;
      setState(() {
        _listCart[item]=val;
      });
    }
  }

  removeElementToList(ListinoProdottiExt item){
    if(checkElementInCart(item)){
      int val = _listCart[item]!;
      val--;
      setState(() {
        if(val>0){
          _listCart[item]=val;

          // _values.remove(item);
          // _filteredValues.remove(item);
        }else{
          _listCart[item]=0;}
      });
    }
  }

  String _calcolaTotaleOrdine(){
     num total=0;
    _values.forEach((value) {
      var price= value.price! * value.quantita!;
      total+=price;
    });
    return total.toStringAsFixed(2);
  }

   _submit() async {
    ///TODO QUA DOVREMMO
    //  _sendOrder = await askContinua(context);
    //  if(_sendOrder!){
    //    setState(() {
    //      _isLoading=true;
    //    });
    //
    //  await _createOrderAndRegisterCartItems();
    //  }
    // setState(() {
    //   _isLoading=false;
    // });
    // debugPrint("delayed end");

  }

  _createOrderAndRegisterCartItems() async {
    Ordine ordine = new Ordine();
    ordine.indirizzoConsegna = _puntoVendita!.indirizzo!;
    ordine.total = num.parse(_calcolaTotaleOrdine());
    ordine.utenteId = AppUtils.utente.profileId!;
    ordine.statoCodice = "INVIATO";
    ordine.pvenditaId = _puntoVendita!.id;
    ordine.note = "note ordine";


    WSResponse  resp = await OrdiniRestService.internal(context).upsertOrdine(ordine);

    if(resp.success!=null && resp.success! && _listCart.length>0) {
      Ordine ordineInviato = OrdiniRestService
          .internal(context)
          .parseList(resp.data!.toList())
          .first;
      List<CartItem> listCartItems = [];
      _listCart.forEach((key, value) {
        if (value > 0) {
          CartItem tmp = new CartItem();
          tmp.orderId = ordineInviato.id;
          tmp.prodId = key.sku;
          tmp.quantita = value;
          tmp.note = "inviato dal cliente";
          listCartItems.add(tmp);
        }
      });


      WSResponse respCart = await CartItemRestService.internal(context)
          .upsertMultipleCartItem(listCartItems);
      if(respCart.success!=null && respCart.success!){
        debugPrint("abbiamo creato ordine e carrello");
      }
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
}
