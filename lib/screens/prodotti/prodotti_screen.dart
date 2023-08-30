import 'package:bufalabuona/data/prodotti_rest_service.dart';
import 'package:bufalabuona/data/utenti_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/prodotti/prodotti_crud.dart';
import 'package:bufalabuona/screens/punti_vendita/punti_vendita_crud.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/punti_vendita_rest_service.dart';
import '../../main.dart';
import '../../model/prodotto.dart';
import '../../utils/ui_icons.dart';


class ProdottiScreen extends StatefulWidget {
  const ProdottiScreen({Key? key}) : super(key: key);

  @override
  State<ProdottiScreen> createState() => _ProdottiScreenState();
}

class _ProdottiScreenState extends State<ProdottiScreen> {
  List<Prodotto>? puntiVenditaList;
  Categoria? _cat;
  bool _isLoading = true;
  String imageUrl='https://stiyidpiphnxmmtmfutn.supabase.co/storage/v1/object/public/public-images/no_picture.png';

  final GlobalKey<ScaffoldState> _refreshKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController _searchController = new TextEditingController();

  List<Prodotto>? _values ;
  List<Prodotto> _filteredValues = [];

  _ProdottiScreenState() {
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
        List<Prodotto> list = _values!.where((v) {
          return v.denominazione!.contains(text.toUpperCase())
              || v.descrizione!.contains(text.toUpperCase());
        }).toList();
        _filteredValues.clear();
        _filteredValues.addAll(list);
      }
    });
  }

  Future<void> readData() async {
    _filteredValues.clear();
    WSResponse resp = await ProdottiRestService.internal(context).getAll();
    if(resp.success!= null && resp.success!){
      setState((){
        _values = ProdottiRestService.internal(context).parseList(resp.data!.toList());
        _filteredValues.addAll(_values!);
      });
    }
    else{
      debugPrint("errore!!");
    }
  }



  List<Categoria> parseList(List responseBody) {
    List<Categoria> list = responseBody
        .map<Categoria>((f) => Categoria.fromJson(f))
        .toList();
    //ordiniamoli dal più recente al più vecchio
    // list.sort((a, b) => b.presId!.compareTo(a.presId!));
    return list;
  }

  @override
  void initState() {
    super.initState();
    _filteredValues.clear();
    init();
  }

  void init() async{
    // await readProdotti();
    await readData();
    setState(() {
      _isLoading=false;
    });
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
          floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child:   Icon(UiIcons.addIco),
          // backgroundColor: const Color(0xFFE57373),
          onPressed: _goToInsert
      ),
      ),
    );
  }

  Widget stackWidget() {
    List<Widget> listWidgets = [];

    var p = Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        body(),
      ],
    );

    listWidgets.add(p);

    // if (_isLoading) {
    //   var modal = new Stack(
    //     children: [
    //       if(_isTapped)  new Opacity(
    //         opacity: 0.7,
    //         child: const ModalBarrier(dismissible: false, color: Colors.black),
    //       ),
    //       new Center(
    //         child: new CircularProgressIndicator(),
    //       ),
    //     ],
    //   );
    //   listWidgets.add(modal);
    // }
    return new Stack(children: listWidgets);
  }

  Widget body() {
    return Expanded(child: Column(
      children: [
        _buildSearchBar(context),
        SizedBox(height: 20),
        Flexible(child: _createList(context)),
      ],
    ));
  }

  Widget _createList(BuildContext context) {
    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._filteredValues.isEmpty) {
      return AppUtils.emptyList(context,FontAwesomeIcons.shopSlash);
    }
    var list = ListView.builder(
        itemCount: _filteredValues.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _filteredValues[position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }





  Widget _buildChildRow(BuildContext context, Prodotto prodotto, int position){
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
                  onTap: ()=> _goToEdit(prodotto),
                  child: Container(
                    foregroundDecoration:(prodotto.dtFinVal!=null) ?
                    // const RotatedCornerDecoration(
                    //   color: Colors.red,
                    //   geometry: const BadgeGeometry(width: 34, height: 34,cornerRadius: 12),
                    //   // textSpan: const TextSpan(
                    //   //   text: 'NON\nATTIVO',
                    //   //   style: TextStyle(fontSize: 11,color: Colors.white),
                    //   // ),
                    // )
                    const RotatedCornerDecoration.withColor(color: Colors.red,  badgeSize: Size(34, 34),
                        badgeCornerRadius: Radius.circular(8),
                        badgePosition: BadgePosition.topEnd)
                        : null,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(prodotto.codice!),
                          Text(prodotto.denominazione!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                          Text(prodotto.descrizione?? ''),
                          Text("${prodotto.quantita} ${prodotto.unimisCodice}"),
                          //TODO inserire dettaglio tipologia punto vendita (market, risto)
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


  void _goToEdit(Prodotto data){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new ProdottiCrud(prodotto: data))).then((value) => _refresh());
  }

  void _goToInsert(){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new ProdottiCrud(prodotto: null ))).then((value) => _refresh());
  }


  Future<void> _refresh() async {
    Fluttertoast.showToast(
        msg: "Refresh",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.redAccent,
        fontSize: 16.0
    );
    _values!.clear();
     readData();
    setState(() {
      _isLoading=false;
    });
  }

  Widget _buildSearchBar(BuildContext context) {
    TextField searchField = TextField(
      style: TextStyle(fontSize: 20.0,
      ),
      controller: _searchController,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText:"Cerca per Nome",
          suffixIcon: IconButton(
              icon: UiIcons.close, onPressed: () => onSearchButtonClear())),
    );

    return Card(
        elevation: 5.0,
        margin: EdgeInsets.all(10.0),
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
}
