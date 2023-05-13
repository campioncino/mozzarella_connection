import 'dart:convert';

import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/data/stato_ordine_rest_service.dart';
import 'package:bufalabuona/model/cart_item.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CarrelloUtenteScreen extends StatefulWidget {
  final Map<ListinoProdottiExt,int> listCart;
  final PuntoVendita? puntoVendita;
  const CarrelloUtenteScreen({Key? key,required this.listCart,required this.puntoVendita}) : super(key: key);

  @override
  State<CarrelloUtenteScreen> createState() => _CarrelloUtenteScreenState();
}

class _CarrelloUtenteScreenState extends State<CarrelloUtenteScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  PuntoVendita? _puntoVendita;

  List<ListinoProdottiExt> _values =[];
  List<ListinoProdottiExt> _filteredValues = [];
  bool _isLoading=true;
  bool? _sendOrder = false;
  late Map<ListinoProdottiExt,int> _listCart;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listCart=this.widget.listCart;
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
    if(_listCart.isNotEmpty){
      setState(() {
        _values.clear();
        _values.addAll(_listCart.keys);
        _filteredValues=_values;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Carrello'),
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: backPressed,
            child: stackWidget()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton :FloatingActionButton.extended(onPressed: _submit,
      label:  Text("Procedi all'ordine",style: TextStyle(fontSize: 22,)),
    isExtended: true,backgroundColor:
    Colors.amberAccent,)
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        puntovenditaCard(),
        Flexible(child: _createList(context)),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text("Totale Ordine ${_calcolaTotaleOrdine()}€",style: TextStyle(fontSize: 24,color:Colors.green,fontWeight: FontWeight.bold),)
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 118.0),
          child: MaterialButton(onPressed: (){},child: Text("Salva carrello",style: TextStyle(color:Colors.blueAccent),),),
        )
      ],
    ));
  }

  Widget _createList(BuildContext context) {
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._filteredValues.isEmpty) {
      return AppUtils.emptyList(context,FontAwesomeIcons.slash);
    }
    var list = ListView.builder(
        itemCount: _filteredValues.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _filteredValues[position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }

  Future<void> _refresh() async{
    _filteredValues.clear();
    _values!.clear();
    readData();
  }

  Widget _buildChildRow(BuildContext context, ListinoProdottiExt listini, int position){
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
                                  Text(listini.prodDenominazione!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                                  Text(listini.prodDescrzione ?? ''),
                                  Text("${listini.prodQuantita} ${listini.prodUnimisDescrizione} "),
                                  Text("${listini.price.toString()} €",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 22,color: Colors.green),)
                                ],
                              ),
                        ),
                          Row(
                            mainAxisAlignment:MainAxisAlignment.spaceBetween ,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(icon: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(width: 2, color: Colors.green)),
                                  child: Icon(FontAwesomeIcons.minus,size: 20,color: Colors.green,)),onPressed: ()=>removeElementToList(listini),),
                              SizedBox(width: 10,),
                              Text(_listCart[listini].toString() ,style: TextStyle(fontSize: 18),),
                              SizedBox(width: 10,),
                              IconButton(icon: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(width: 2, color: Colors.green)),child: Icon(FontAwesomeIcons.plus,size: 20,color: Colors.green,)),onPressed: ()=>addElementToList(listini),)

                            ],
                          ),
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


  Widget puntovenditaCard(){
    return Container(
      color: Colors.teal[50],
      width: MediaQuery.of(context).size.width,
      child: ListTile(leading: Icon(FontAwesomeIcons.locationDot,color: Colors.black54),
        title: Text("Invia a : ${_puntoVendita!.indirizzo?? 'NESSUN INDIRIZZO SPECIFICATO'}",style: TextStyle(fontStyle: FontStyle.italic),),
        trailing: IconButton(icon: Icon(FontAwesomeIcons.pencil),onPressed: (){},),
      ),
    );
  }

    Future<bool> backPressed() async {
      Navigator.pop(context, this._listCart);
      return true;
    }

  bool checkElementInCart(ListinoProdottiExt item){
    debugPrint(_listCart.toString());
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
    _listCart.forEach((key, value) {
      var price= key.price! * value;
      total+=price;
    });
    return total.toString();
  }

   _submit() async {

     _sendOrder = await askContinua(context);
     if(_sendOrder!){
       setState(() {
         _isLoading=true;
       });

     await _createOrderAndRegisterCartItems();
     }
    setState(() {
      _isLoading=false;
    });
    debugPrint("delayed end");

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
