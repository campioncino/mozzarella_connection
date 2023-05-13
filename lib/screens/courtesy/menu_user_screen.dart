import 'dart:ffi';

import 'package:bufalabuona/data/cart_item_rest_service.dart';
import 'package:bufalabuona/data/listini_prodotti_rest_service.dart';
import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/model/cart_item_ext.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/ordine_ext.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/login/profile_screen.dart';
import 'package:bufalabuona/screens/ordini/storico_ordini_utente_screen.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

import '../clienti/home.dart';

class MenuUserScreen extends StatefulWidget {

  final Map<String?, dynamic>? options;
  const MenuUserScreen({Key? key,required this.options}) : super(key: key);

  @override
  State<MenuUserScreen> createState() => _MenuUserScreenState();
}

class _MenuUserScreenState extends State<MenuUserScreen> {

  final RoundedLoadingButtonController _submitController = RoundedLoadingButtonController();
  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');
  final dateFormatter = new DateFormat('dd-MM-yyyy');

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
  final globalKey = GlobalKey<ScaffoldState>();

  bool _isLoading=true;

  final TextEditingController _storicoOrdini= new TextEditingController(text: "Visualizza lo storico ordiini");
  final TextEditingController _accountController= new TextEditingController(text: "Modifica Acccount");
  final TextEditingController _latOrderController= new TextEditingController(text: "Ripeti Ultimo Ordine");


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
            body: WillPopScope(
                onWillPop: ()=>_goHome(),
                child: stackWidget())));
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
              child: Align(alignment:Alignment.bottomLeft,child: Padding(
                padding: const EdgeInsets.fromLTRB(18.0,18,18,10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(FontAwesomeIcons.solidCircleUser,size: 66,color: Colors.white,),
                    SizedBox(width: 22,),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Ciao ,",style: TextStyle(color: Colors.white,fontSize: 22),),
                          Text("${AppUtils.utente.name}!",style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w800),maxLines: 3,),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
              width: MediaQuery.of(context).size.width,
               height: MediaQuery.of(context).size.height/15*3,
              color: Color(0xFF3BBAD5),
            ),
            storicoOrdiniCard(),
            accountCard(),
            lastOrderCard(),
            // ripetiUltimoOrdineCard(),
            SizedBox(height: 100,)
          ]),
    ));}




  Widget storicoOrdiniCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 4.0,right: 4.0, top: 8,bottom:0),
      child: Card(
        child: Container(
          // color: Color(0xFF3BBAD5),
          // color:Colors.lightBlue[300],
          width: MediaQuery.of(context).size.width,
          child: ListTile(leading: Icon(FontAwesomeIcons.boxArchive,color: Colors.black54,size: 36,),
              title: TextFormField(
                maxLines: 2,
                controller: _storicoOrdini,
                decoration: InputDecoration(
                    disabledBorder: InputBorder.none,
                    labelText: "Storico Ordini",
                enabled: false,
              )),
              trailing: IconButton(icon: Icon(Icons.chevron_right,color: Colors.black54,),
                  onPressed: _goStorico
              )
          ),
        ),
      ),
    );
  }

  Widget accountCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 2.0,right: 2.0, top: 4,bottom:0),
      child: Card(
        child: Container(
          // color: Color(0xFF3BBAD5),
          // color:Colors.lightBlue[300],
          width: MediaQuery.of(context).size.width,
          child: ListTile(leading: Icon(FontAwesomeIcons.userGear,color: Colors.black54,size: 36,),
              title: TextFormField(
                  maxLines: 2,
                  controller: _accountController,
                  decoration: InputDecoration(
                    disabledBorder: InputBorder.none,
                    labelText: "Impostazioni",
                    enabled: false,
                  )),
              trailing: IconButton(icon: Icon(Icons.chevron_right,color: Colors.black54,),
                  onPressed: _goToProfile
              )
          ),
        ),
      ),
    );
  }

  Widget lastOrderCard(){
    return Padding(
      padding: const EdgeInsets.only(left: 2.0,right: 2.0, top: 4,bottom:0),
      child: Card(
        child: Container(
          // color: Color(0xFF3BBAD5),
          // color:Colors.lightBlue[300],
          width: MediaQuery.of(context).size.width,
          child: ListTile(leading: Icon(FontAwesomeIcons.repeat,color: Colors.black54,size: 36,),
              title: TextFormField(
                  maxLines: 2,
                  controller: _latOrderController,
                  decoration: InputDecoration(
                    disabledBorder: InputBorder.none,
                    labelText: "Ordine Veloce",
                    enabled: false,
                  )),
              trailing: IconButton(icon: Icon(Icons.chevron_right,color: Colors.black54,),
                  onPressed:()=> _repeatLastOrder(AppUtils.puntoVendita)
              )
          ),
        ),
      ),
    );
  }



  void _goStorico(){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>new StoricoOrdiniScreen(puntoVendita: this.widget.options!['puntoVendita'])));
  }

  void _goToProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfileScreen(options: this.widget.options,)));
  }

  Future<void>  _repeatLastOrder(PuntoVendita p) async{
   setState(() {
     _isLoading=true;
   });
    Map<ListinoProdottiExt,int> listCart={};
    OrdineExt? tmp = await getLastOrdine(p);
    List<CartItemExt>? listCartItem;
    if(tmp!=null && tmp.id!=null){
      listCartItem = await getItemsFromOrdine(tmp);
    }
    if(listCartItem!=null && listCartItem.isNotEmpty){
      /// AGGIUNGIAMO UNICAMENTE I PRODOTTI DEL VECCHIO ORDINE CHE SONO ALL'INTERNO DEL LISTINO
      List<ListinoProdottiExt>? listProd =await getListino(p);
      listCartItem.forEach((element) {
        ListinoProdottiExt? p = listProd?.firstWhere((el) => el.sku==element.prodId);
          listCart[p!]=int.parse(element.quantita.toString());
      });
    }

    if(listCart!=null && listCart.isNotEmpty){
      AppUtils.clearCartItems();
      AppUtils.storeCartItems(listCart);
    }
   setState(() {
     _isLoading=false;
   });
    _goHome();
   // Navigator.push(context,  MaterialPageRoute(
   //     builder: (context) =>new Home(options: this.widget.options,listCart: listCart,)));
  }



  Future<OrdineExt?> getLastOrdine(PuntoVendita p) async {
    OrdineExt? result;
    WSResponse resp = await OrdiniRestService.internal(context).getOrdiniByPuntoVenditaId(p!.id);
    if(resp.success!= null && resp.success!){
      setState((){
        List<OrdineExt> _values = OrdiniRestService.internal(context).parseListExt(resp.data!.toList());
       result =_values.first;
      });
    }
    else{
      debugPrint("errore!!");
    }
    return result;
  }

  Future<List<CartItemExt>?> getItemsFromOrdine(OrdineExt? o) async {
    List<CartItemExt>? result;
    WSResponse resp = await CartItemRestService.internal(context).getCartItemByOrdineId(o!.id!);
    if(resp.success!= null && resp.success!){
      setState((){
        result = CartItemRestService.internal(context).parseListExt(resp.data!.toList());
      });
    }
    else{
      debugPrint("errore!!");
    }
    return result;
  }

  Future<List<ListinoProdottiExt>?> getListino(PuntoVendita p) async {
    List<ListinoProdottiExt>? result;
    WSResponse resp = await ListiniProdottiRestService.internal(context).getListinoByCatId(p.catId!);
    if(resp.success!= null && resp.success!){
      setState((){
        result = ListiniProdottiRestService.internal(context).parseListExt(resp.data!.toList());
      });
    }
    else{
      debugPrint("errore!!");
    }
    return result;
  }

  _goHome(){
    Map<String,dynamic>? options = new Map();
    options['utente']=AppUtils.utente;
    options['puntoVendita']=AppUtils.puntoVendita;
    options['route']= 'PRODOTTI';
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false, arguments: options);
  }
}
