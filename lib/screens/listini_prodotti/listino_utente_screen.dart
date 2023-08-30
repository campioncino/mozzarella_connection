import 'dart:convert';

import 'package:badges/badges.dart';
import 'package:bufalabuona/data/categorie_prodotti_rest_service.dart';
import 'package:bufalabuona/data/listini_prodotti_rest_service.dart';
import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/model/categoria_prodotto.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/avatar.dart';
import 'package:bufalabuona/screens/carrello/carello_utente_screen.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' show toBeginningOfSentenceCase;
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../../utils/ui_icons.dart';
import '../home_clienti/home.dart';


class ListinoUtenteScreen extends ConsumerStatefulWidget {
  final PuntoVendita? puntoVendita;
  final Map<ListinoProdottiExt,int> listCart;
  const ListinoUtenteScreen({Key? key,@required this.puntoVendita,required this.listCart}) : super(key: key);

  @override
  ConsumerState<ListinoUtenteScreen> createState() => _ListinoUtenteScreenState();
}

class _ListinoUtenteScreenState extends ConsumerState<ListinoUtenteScreen> {

  List<CategoriaProdotto> _listCategoriaProdotto=[];

  PuntoVendita? _puntoVendita;
  bool _showSearchBar=true;
  String imageUrl='https://stiyidpiphnxmmtmfutn.supabase.co/storage/v1/object/public/public-images/no_picture.png';

  bool _isLoading = true;
  ScrollController _scrollController = new ScrollController();
  final TextEditingController _searchController = new TextEditingController();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
   List<FileObject> listImages=[];

  List<ListinoProdottiExt>? _values ;
  List<ListinoProdottiExt> _filteredValues = [];

  TextEditingController _textFieldQuantityController = new TextEditingController();

  Map<ListinoProdottiExt,int> _listCart ={};

  _ListinoUtenteScreenState() {
    _searchController.addListener(() {
      handleSearch(_searchController.text);
    });
  }

  void handleSearch(String text) {
    setState(() {
      if (text.isEmpty) {
        _filteredValues.clear();
        debugPrint(_values.toString());
        _filteredValues.addAll(_values!);
      } else {
        List<ListinoProdottiExt> list = _values!.where((v) {
          return v.prodDescrzione!.contains(text.toUpperCase()) || v.prodDenominazione!.contains(text.toUpperCase());
        }).toList();
        _filteredValues.clear();
        _filteredValues.addAll(list);
      }
    });
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _puntoVendita = this.widget.puntoVendita;

    _listCart=this.widget.listCart;
    if(_listCart==null){
      _listCart = new Map();
    }
    _filteredValues.clear();
    init();
  }

  void init() async{
    await readData();
    await retrieveImages();
    await readCategoriaProdotto();
    setState(() {
      _isLoading=false;
    });
  }


  readData() async {
    WSResponse resp = await ListiniProdottiRestService.internal(context)
        .getListinoByCatId(_puntoVendita!.catId!);
    if (resp.data != null) {
      if (resp.success != null && resp.success!) {
        setState(() {
          _values = ListiniProdottiRestService.internal(context).parseListExt(
              resp.data!);
          _filteredValues.addAll(_values!);
        });
      }
      else {
        debugPrint("errore listino prodotti");
      }
    }
  }

  readCategoriaProdotto() async {
    WSResponse resp = await CategorieProdottiRestService.internal(context)
        .getAll();
    if (resp.data != null) {
      if (resp.success != null && resp.success!) {
        setState(() {
          _listCategoriaProdotto.addAll(CategorieProdottiRestService.internal(context).parseList(
              resp.data!));
        });
      }
      else {
        debugPrint("errore categoria prodotti");
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: null,
            child: stackWidget()),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

        // floatingActionButton :FloatingActionButton.extended(onPressed: goToCart,
        //     isExtended: true,
        //     backgroundColor: Colors.amberAccent,
        //     icon: Badge(
        //         badgeColor: Colors.lightGreen,
        //         showBadge: _listCart.isNotEmpty,
        //         badgeContent:  Text(_listCart.length.toString(), style: const TextStyle(
        //             color: Colors.black,  //badge font color
        //             fontSize: 16 //badge font size
        //         )
        //         ),
        //         child: UiIcons.cartShopping),
        //     splashColor: Colors.grey,
        //   label: const Padding(
        //       padding: EdgeInsets.symmetric(horizontal: 18.0),
        //       child: Text("Vai Al Carrello",style: TextStyle(fontSize: 22),),
        //     ),
        // ),
      ),
    );
  }

  Widget stackWidget() {
    List<Widget> listWidgets = [];


    var p = Container(
       color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          body(),
        ],
      ),
    );
    listWidgets.add(p);
    return new Stack(children: listWidgets);
  }


  Widget body(){
    return NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (_scrollController.position.userScrollDirection ==
              ScrollDirection.reverse) {
            setState((){
              _showSearchBar=false;
            });
          } else if (_scrollController.position.userScrollDirection ==
              ScrollDirection.forward) {
            setState((){
              _showSearchBar=true;
            });
          }
          return true;
        },
        child: body2());
  }
  Set<CategoriaProdotto> filters = <CategoriaProdotto>{};

  Widget body2() {
    return Expanded(child: Column(
      children: [
        if(_showSearchBar) _buildSearchBar(context),
        // _buildChipValues(),
        SizedBox(height: 20),
        Flexible(child: _createList(context)),
        // SizedBox(height: 80)
      ],
    ));
  }


  Widget _createList(BuildContext context) {
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._filteredValues.isEmpty) {
      return AppUtils.emptyList(context,UiIcons.emptyIco);
    }
    var list = ListView.builder(
        shrinkWrap: true,
        physics: AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        itemCount: _filteredValues.length,
        itemBuilder: (context, position) {
            return _buildChildRow(context, _filteredValues[position], position);

        });

    // var list = GridView.builder(
    //         shrinkWrap: true,
    //         gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
    //             maxCrossAxisExtent:350,
    //             childAspectRatio:4/6,
    //             crossAxisSpacing: 3,
    //             mainAxisSpacing: 3
    //         ),
    //         itemCount: _filteredValues.length,
    //         itemBuilder: (context, position) {
    //           return _buildChildMatrix(context, _filteredValues[position], position);
    //         });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }

  Widget _buildChildRow(BuildContext context, ListinoProdottiExt listino, int position) {
    return Padding(
      padding: const EdgeInsets.fromLTRB( 8.0,4,8,4),
      child: Card(
        shadowColor: Colors.grey.shade800,
          borderOnForeground: true,
          surfaceTintColor: Colors.white70,
          margin: EdgeInsets.all(5.0),
          elevation: 1.0,
          child:Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              prodottoDrawItemRow(listino, position),
              // addElementWidget(listino)
            ],
          )),
    );}


  Widget _buildChildMatrix(BuildContext context, ListinoProdottiExt listino, int position) {
    return Padding(
      padding: const EdgeInsets.fromLTRB( 8.0,4,8,4),
      child: Card(
          shadowColor: Colors.grey.shade800,
          borderOnForeground: true,
          surfaceTintColor: Colors.white70,
          margin: EdgeInsets.all(5.0),
          elevation: 4.0,
          child:Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              prodottoDrawItemColumn(listino, position),
              buttonAdd(listino)
            ],
          )),
    );}





  bool checkElementInCart(ListinoProdottiExt item){
    bool isPresent=false;
    _listCart.forEach((key, value) {if(key.prodId!=null && key.prodId==item.prodId){
      isPresent=true;
    }});
    return isPresent;
  }

   addElementToList(ListinoProdottiExt item) async{
    debugPrint(item.sku!.toString());
    if(checkElementInCart(item)){
      int val = _listCart.entries.firstWhere((element) => element.key.sku==item.sku).value ;
      val++;
      ref.read(counterStateProvider.notifier).state++;
      setState(() {
        _listCart[_listCart.keys.where((element) => element.sku==item.sku).first]=val;
        // _listCart[item]=val;
      });
    }else{
      addFirstElement(item);
    }
    AppUtils.clearCartItems();
    AppUtils.storeCartItems(_listCart);
  }

  removeElementToList(ListinoProdottiExt item) async{
    if(checkElementInCart(item)){
      int val = _listCart.entries.firstWhere((element) => element.key.sku==item.sku).value ;
      if(val>0){
      val--;
      ref.read(counterStateProvider.notifier).state--;
      }
      setState(() {
        if(val>0){
          _listCart[_listCart.keys.where((element) => element.sku==item.sku).first]=val;
        }else{
          _listCart.removeWhere((key, value) => key.sku == item.sku);
        }
      });
    }
    AppUtils.clearCartItems();
    AppUtils.storeCartItems(_listCart);
  }

   addFirstElement(ListinoProdottiExt item) async{
     ref.read(counterStateProvider.notifier).state++;
     setState(() {
      _listCart[item]=1;
    });
     AppUtils.clearCartItems();
     AppUtils.storeCartItems(_listCart);
  }

  showSearchBar(){
    setState(() {
      _showSearchBar=!_showSearchBar;
    });
  }

  Widget prodottoDrawItemRow(ListinoProdottiExt listino,int position){

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          // _sizedContainer(CachedNetworkImage(
          //   imageUrl: listino.imageUrl ?? '',
          //   placeholder: (context, url) =>
          //   const CircularProgressIndicator(),
          //   errorWidget: (context, url, error) => const UiIcons.error,
          // )
          // ),
            if (listino.imageUrl == null || listino.imageUrl!.isEmpty)
              Container(
                width: 150,
                height: 150,
                color: Colors.grey[50],
                child:  Center(
                  child: Image.asset('assets/images/no_picture.png'),
                ),
              )
            else
              _sizedContainer(
                CachedNetworkImage(
                  imageUrl: listino.imageUrl!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                  const CircularProgressIndicator(),
                  errorWidget: (context, url, error) =>  UiIcons.error,
                ),
              ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18,0,18,0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                Text(listino.prodDenominazione!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey.shade800)),
                price(listino),
                Text(listino.prodDescrzione!),
                SizedBox(height: 8,),
                addElementWidget(listino)
                ],),
            ),
          )
        ],),
      ],
    );
  }

  Widget prodottoDrawItemColumn(ListinoProdottiExt listino,int position){
    if (listImages.any((val) => val.name.split('.')[0] == listino.prodCodice!.toUpperCase())) {
      imageUrl = supabase
          .storage
          .from('public-images')
          .getPublicUrl('${listino.prodCodice!.toUpperCase()}.png');
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _sizedContainer(CachedNetworkImage(
          imageUrl: imageUrl,
          placeholder: (context, url) =>
          const CircularProgressIndicator(),
          errorWidget: (context, url, error) =>  UiIcons.error,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(listino.prodDenominazione!,style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold,color: Colors.grey.shade800)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: price(listino),
        ),

      ],
    );
  }

  Widget buttonAdd(ListinoProdottiExt listino){
    return Container(child :checkElementInCart(listino)?
    Row(
      mainAxisAlignment:MainAxisAlignment.spaceEvenly ,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(icon: Icon(LineAwesomeIcons.minus_circle),onPressed: removeElementToList(listino)),
        // IconButton(icon: Container(
        //     decoration: BoxDecoration(
        //         borderRadius: BorderRadius.circular(70),
        //         border: Border.all(width: 2, color: Colors.blueGrey)),
        //     child: Icon(UiIcons.minusIco,size: 28,color: Colors.grey,)),
        //   onPressed: removeElementToList(listino),),
        SizedBox(width: 10,),
          Text(_listCart[listino].toString(),style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
        SizedBox(width: 10,),
        IconButton(icon: Icon(LineAwesomeIcons.plus_circle), onPressed: addElementToList(listino),)
        // IconButton(icon: Container(
        //     decoration: BoxDecoration(
        //         color: Colors.lightBlueAccent,
        //         borderRadius: BorderRadius.circular(100),
        //         border: Border.all(width: 5, color: Colors.lightBlueAccent)),child: UiIcons.plys),onPressed: addElementToList(listino),)

      ],
    )
        :MaterialButton(onPressed: addFirstElement(listino),child: Icon(LineAwesomeIcons.add_to_shopping_cart),)

    );
  }

  Widget addElementWidget( ListinoProdottiExt listino){
    return  Container(
      child:checkElementInCart(listino)?
      Row(
        mainAxisAlignment:MainAxisAlignment.spaceEvenly ,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(icon: UiIcons.minus,onPressed: ()=>removeElementToList(listino)),

          // IconButton(icon: Container(
          //     decoration: BoxDecoration(
          //         borderRadius: BorderRadius.circular(70),
          //         border: Border.all(width: 2, color: Colors.teal[900]!)),
          //     child: Icon(UiIcons.minusIco,size: 28,color: Colors.black54,)),onPressed: ()=>removeElementToList(listino),),
          SizedBox(width: 10,),
          Text(_listCart.entries.firstWhere((element) => element.key.sku==listino.sku).value.toString(),style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
          // GestureDetector(
          //     onTap:()=>_displayTextInputDialog(context,listino),
          //     child: Text(_listCart.entries.firstWhere((element) => element.key.sku==listino.sku).value.toString(),style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),)),
          SizedBox(width: 10,),
          IconButton(icon: Container(
              decoration: BoxDecoration(
                  color: Colors.teal[800],
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(width: 5, color: Colors.teal[800]!)),child: UiIcons.plus),onPressed: ()=>addElementToList(listino),)

        ],
      ) : Padding(
        padding: const EdgeInsets.symmetric(horizontal:.0,vertical: 6),
        child:
        ElevatedButton(
            style: ElevatedButton.styleFrom(
                side:  BorderSide(
                    width: 1, // the thickness
                    color: Colors.teal[800]! // the color of the border
                ),
              backgroundColor: Colors.white
            ),
            onPressed:(){addFirstElement(listino);},
          child:

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                UiIcons.cartShoppingAdd,
                // SizedBox(width: 20,),
                Text("ADD",style: TextStyle(fontSize: 16,color:Colors.teal[800])),
                  SizedBox(width: 20)],
                )
          // ListTile(title: Text("ADD",style: TextStyle(fontSize: 18,color:Colors.green)),leading:  UiIcons.cartPlusIco,color: Colors.green),)
        ),
      ),
    );
  }





  Widget price(ListinoProdottiExt item){
    return  Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("${item.price!.toString()}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 23,color: Colors.green[800]),),
        Text("€/${item.prodUnimisCodice!.toLowerCase()}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: Colors.green[800]),),
      ],
    );
  }

  Widget denominazione(ListinoProdottiExt item){
    String denominazione='';
    item.prodDenominazione!.split(' ').forEach((element) {
      String? val = toBeginningOfSentenceCase(element.toLowerCase());
      denominazione+=(val)!+'\n';
    });
    // return Expanded(child: Text(denominazione,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)));
    return Expanded(child: Text(item.prodDenominazione!,style: TextStyle(fontSize: 66,fontWeight: FontWeight.bold)));
  }


  Future<void> _refresh() async{
    _filteredValues.clear();
    _values!.clear();
    readData();
    retrieveImages();
    _searchController.text='';
  }

  Widget _buildSearchBar(BuildContext context) {
    TextField searchField = TextField(
      style: TextStyle(fontSize: 20.0,),
      controller: _searchController,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText:"Cerca per Nome",
          suffixIcon: IconButton(
              icon: UiIcons.close, onPressed: () => onSearchButtonClear())),
    );

    return Card(
        elevation: 5.0,
        margin: EdgeInsets.fromLTRB(10.0,10.0,10.0,0.0),
        child:  Padding(
          padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
          child: searchField,
        ));
  }

  Future onSearchButtonClear() async {
    setState(() {
      //This is not working. Exception - invalid text selection: TextSelection(baseOffset: 2, extentOffset: 2, affinity: TextAffinity.upstream, isDirectional: false)
      //ref https://github.com/flutter/flutter/issues/17647
      //_searchController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchController.clear());
    });
  }

  Widget _buildChipValues(){
    List<Widget> listChips=[];
    _listCategoriaProdotto!.forEach((element) {
      listChips.add(FilterChip(
        label: Text(element.descrizione!),
        selected: filters.contains(element),
        onSelected: (bool selected) {
          setState(() {
            if (selected) {
              filters.add(element);
            } else {
              filters.remove(element);
            }
          });
        },
      ));
    });
    return Wrap(
        spacing: 5.0,
        children:listChips);
  }

  goToCart(){
    Navigator.push(context, MaterialPageRoute(
         builder: (context) =>
    new CarrelloUtenteScreen(puntoVendita: _puntoVendita,listCart: _listCart,))).then((value){
      Map<ListinoProdottiExt, int> tmp = value;
      tmp.removeWhere((key, val) => val==0);

      _listCart.addAll(tmp);

      setState(() {
       _listCart;
      });
    } );

  }

  Widget _sizedContainer(Widget child) {
    return SizedBox(
      width: 150.0,
      height: 150.0,
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: child,
      ),
    );
  }

  retrieveImages() async {
    listImages = await supabase
        .storage
        .from('public-images')
        .list();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


  Future<void> _displayTextInputDialog(BuildContext context,ListinoProdottiExt listino) async {
    _textFieldQuantityController.clear();
    String valueText=(_listCart.entries.firstWhere((element) => element.key.sku==listino.sku).value.toString());
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Inserisci la quantità'),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  valueText = value;
                });
              },
              controller: _textFieldQuantityController,
              decoration:
               InputDecoration(hintText: valueText),
            ),
            actions: <Widget>[
              MaterialButton(
                // color: Colors.red,
                // textColor: Colors.white,
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              MaterialButton(
                // color: Colors.green,
                // textColor: Colors.white,
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    _listCart[_listCart.keys.where((element) => element.sku==listino.sku).first]=int.parse(valueText);
                    // _listCart[item]=val;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
