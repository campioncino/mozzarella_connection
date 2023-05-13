import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/listini_rest_service.dart';
import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/carrello/carello_checkout_admin_screen.dart';
import 'package:bufalabuona/screens/listini_prodotti/listini_prodotti_screen.dart';
// import 'package:bufalabuona/screens/prodotti/lov_prodotti_fragment.dart';
import 'package:bufalabuona/utils/app_utils.dart';
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
  // List<CartItemExt> _filteredValues = [];
  bool _isLoading=true;
  bool _isReadOnly = true;
  Map<ListinoProdottiExt,int> _listCart = Map();

  final TextEditingController _dataSpedizioneController = new TextEditingController();
  final TextEditingController _noteController = new TextEditingController();

  final RoundedLoadingButtonController _submitController = RoundedLoadingButtonController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _ordine=this.widget.ordine;
    _puntoVendita=this.widget.puntoVendita;
    // _filteredValues.clear();
    _isReadOnly =_ordine!.statoCodice=='INVIATO' ? false : true;
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
          // _filteredValues.addAll(_values);
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
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                destinatario(),
                if(!_isReadOnly)
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
        SizedBox(height: 100,)
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
    // _filteredValues.clear();
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
                                      color: _isReadOnly ? Colors.grey :Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(width: 4, color: _isReadOnly ? Colors.grey :Colors.white)),
                                  child: (listini.quantita!=null && listini.quantita!>1) ? Icon(FontAwesomeIcons.minus,size: 20,color: _isReadOnly ? Colors.white70 :Colors.black54):Icon(FontAwesomeIcons.trash, size: 22, color: _isReadOnly ? Colors.white70 : Colors.red,)),
                                    onPressed:  _isReadOnly ? null : (){setState(() {
                                    if(listini.quantita!>0){listini.quantita = listini.quantita!-1;}
                                  });}),
                              SizedBox(width: 10,),
                              Text(listini.quantita.toString() ,style: TextStyle(fontSize: 18,fontWeight: FontWeight.w700),),
                              SizedBox(width: 10,),
                              IconButton(
                                icon: Container(
                                    decoration: BoxDecoration(
                                        color: _isReadOnly ? Colors.grey :Colors.teal[800],
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            width: 5,
                                            color:  _isReadOnly ? Colors.grey :Colors.teal[800]!,)),
                                    child: Icon(
                                      FontAwesomeIcons.plus,
                                      size: 20,
                                      color: Colors.white70,
                                    )),
                                onPressed: _isReadOnly ? null : () {
                                  setState(() {
                                    if (listini.quantita != null) {
                                      listini.quantita = listini.quantita! + 1;
                                      _calcolaTotaleOrdine();
                                    }
                                  });
                                },
                              )
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
      ],),
    ),);
  }

  Widget puntoVenditaCard(){
    return ListTile(
        leading: Icon(FontAwesomeIcons.house),
    title:Text("${_puntoVendita!.denominazione}"),
        subtitle: Text("${_puntoVendita!.ragSociale}"));

  }

  Widget ordineCard(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        Text("Ordine #${_ordine!.numero}",style: TextStyle(fontWeight: FontWeight.w600),),
        Text("del ${AppUtils.convertTimestamptzToStringDate(_ordine!.createdAt!??'')?.substring(0,10)}"),
      ],),
    );}

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
    return total.toString();
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
        cartItemTmp.note='Inserito dal Venditore';
        cartItemTmp.statoCodice='PROPOSTO';
        debugPrint(cartItemTmp.toJson().toString());
        bool _isPresent =  _adminValues.any((element) => element.prodId==cartItemTmp.prodId ?? false);
        if(!_isPresent) {
          setState(() {
            _adminValues.add(cartItemTmp);
            _calcolaTotaleOrdine();
          });
        }else{
          AppUtils.errorSnackBar(_scaffoldKey, "Prodotto già presente nel carrello");
        }
      }
    });

  }

  Widget totaleOrdineCard(){
    return Text("Totale Ordine ${_calcolaTotaleOrdine()}€",style: TextStyle(fontSize: 24,color:Colors.teal[800],fontWeight: FontWeight.bold),);
  }

  Widget checkoutButton(){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
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
    // if(_listCart!=null && _listCart.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(
          builder: (context) =>
          new CarrelloCheckoutAdminScreen(
            puntoVendita: _puntoVendita, ordine: _ordine, adminValues: _adminValues, readOnlyMode: _isReadOnly,)));
    // }

  }

}
