import 'dart:convert';

import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/data/stato_ordine_rest_service.dart';
import 'package:bufalabuona/model/cart_item.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/clienti/home.dart';
import 'package:bufalabuona/screens/courtesy/confirmed_order_screen.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import 'carello_checkout_screen.dart';


class CarrelloUtenteScreen extends ConsumerStatefulWidget {
  final Map<ListinoProdottiExt,int> listCart;
  final PuntoVendita? puntoVendita;
  const CarrelloUtenteScreen({Key? key,required this.listCart,required this.puntoVendita}) : super(key: key);

  @override
  ConsumerState<CarrelloUtenteScreen> createState() => _CarrelloUtenteScreenState();
}

class _CarrelloUtenteScreenState extends ConsumerState<CarrelloUtenteScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final globalKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _submitController = RoundedLoadingButtonController();
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
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: backPressed,
            child: stackWidget()),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: checkoutButton(),
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
        TextButton(onPressed:_svuotaCarello, child: Text("Svuota Carrello")),
        Flexible(child: _createList(context)),
        SizedBox(height: 100,)
      ],
    ));
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
                controller: _submitController,child: Text("Prosegui",style: TextStyle(fontSize: 22,color: Colors.black),)),
          )
        ],
      ),
    );
  }

  _submit() async {
    setState(() {
      _submitController.reset();
    });
    if(_listCart!=null && _listCart.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) =>
          new CarelloCheckoutScreen(
            puntoVendita: _puntoVendita, listCart: _listCart,)));
    }

  }


  _svuotaCarello() async{
    if(_listCart.isNotEmpty){
    bool? check = await askSvuota(context);
    ref.read(counterStateProvider.notifier).state=0;
    AppUtils.clearCartItems();
    if(check!){

      setState(() {
      _listCart.clear();
      _values.clear();
      _filteredValues.clear();
    });}}
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
    _values.clear();
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
                                  Text("${listini.price.toString()} € / ${listini.prodUnimisCodice!.toLowerCase()}",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 16))
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
                                  child: (_listCart[listini]!=null && _listCart[listini]!>1) ? Icon(FontAwesomeIcons.minus,size: 20,color: Colors.black54):Icon(FontAwesomeIcons.trash, size: 22, color: Colors.red,)),onPressed: ()=>removeElementToList(listini),),
                              SizedBox(width: 10,),
                              Text(_listCart[listini].toString() ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
                              SizedBox(width: 10,),
                              IconButton(icon: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.teal[800],
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(width: 5, color: Colors.teal[800]!)),child: Icon(FontAwesomeIcons.plus,size: 20,color: Colors.white70,)),onPressed: ()=>addElementToList(listini),)

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0,10,7,10),
              child: Text("€ ${_calcolaParzialeOrdine(listini)}",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 20,color: Colors.teal[800],fontWeight: FontWeight.w700) ,),
            ),
          ],
        ),
      ],
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
      ref.read(counterStateProvider.notifier).state++;
      setState(() {
        _listCart[item]=val;
      });
      AppUtils.clearCartItems();
      AppUtils.storeCartItems(_listCart);
    }
  }

  removeElementToList(ListinoProdottiExt item){
    if(checkElementInCart(item)){
      int val = _listCart[item]!;
      if(val>0) {
        val--;
        ref.read(counterStateProvider.notifier).state--;
        AppUtils.clearCartItems();
        AppUtils.storeCartItems(_listCart);
      }
      setState(() {
        if(val>0){
          _listCart[item]=val;
          // _values.remove(item);
          // _filteredValues.remove(item);
        }else{
          _listCart.removeWhere((key, value) => key.sku == item.sku);
          _filteredValues.removeWhere((element) => element.sku==item.sku);
        }
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

  String _calcolaParzialeOrdine(ListinoProdottiExt listino){
    num parziale = 0;
    _listCart.forEach((key,value){
      if(key.sku==listino.sku){
        parziale= key.price! * value;
      }
    });
    return parziale.toString();
  }


  Future<bool?> askSvuota(BuildContext context) async {
    String title = "Attenzione";
    String message ="Vuoi eliminare tutti gli articoli presenti nel carrello?";
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
                child: Text("OK",),
                onPressed: () {
                  Navigator.pop(context,true);
                }),
          ]
      ),
    );
    return ok!;
  }

}
