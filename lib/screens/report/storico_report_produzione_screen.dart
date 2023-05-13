import 'package:bufalabuona/data/ordini_rest_service.dart';
import 'package:bufalabuona/data/prodotti_rest_service.dart';
import 'package:bufalabuona/data/utenti_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/ordine.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/carrello/carello_dettaglio_admin_screen.dart';
import 'package:bufalabuona/screens/carrello/carello_dettaglio_screen.dart';
import 'package:bufalabuona/screens/prodotti/prodotti_crud.dart';
import 'package:bufalabuona/screens/punti_vendita/punti_vendita_crud.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../../data/punti_vendita_rest_service.dart';
import '../../model/ordine_ext.dart';
import '../../model/prodotto.dart';


class StoricoOrdiniAdminScreen extends StatefulWidget {
  const StoricoOrdiniAdminScreen({Key? key}) : super(key: key);

  @override
  State<StoricoOrdiniAdminScreen> createState() => _StoricoOrdiniAdminScreenState();
}

class _StoricoOrdiniAdminScreenState extends State<StoricoOrdiniAdminScreen> {
  Categoria? _cat;
  bool _isLoading = true;
  bool _withConfermato = false;

  // PuntoVendita? _puntoVendita;

  final GlobalKey<ScaffoldState> _refreshKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController _searchController = new TextEditingController();

  List<OrdineExt>? _values ;
  List<OrdineExt> _filteredValues = [];

  _StoricoOrdiniAdminScreenState() {
    _searchController.addListener(() {
      handleSearch(_searchController.text);
    });
  }

  void handleSearch(String text) {
    setState(() {
      if (text.isEmpty) {
        _filteredValues.clear();
        print(_values.toString());
        _filteredValues.addAll(_values!);
      } else {
        List<OrdineExt> list = _values!.where((v) {
          return v.createdAt!.contains(text.toUpperCase())
              || v.statoCodice!.contains(text.toUpperCase())
              || v.pvenditaDenominazione!.toUpperCase().contains(text.toUpperCase());
        }).toList();
        _filteredValues.clear();
        _filteredValues.addAll(list);
      }
    });
  }

  Future<void> readData() async {
    _filteredValues.clear();
    WSResponse resp = await OrdiniRestService.internal(context).getAllOrdini(_withConfermato);
    if(resp.success!= null && resp.success!){
      setState((){
        _values = OrdiniRestService.internal(context).parseListExt(resp.data!.toList());
        _filteredValues.addAll(_values!);
      });
    }
    else{
      debugPrint("errore!!");
    }
  }

  Widget _includiConfermato(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Expanded(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Includi ordini Confermati",style: TextStyle(fontSize: 20),),
        )),
        Switch(
          activeColor: Colors.green,
          inactiveThumbColor: Colors.redAccent,
          value: _withConfermato,
          onChanged: (bool value) {
              setState(() {
                _withConfermato = value;
                readData();
              });}
        ),]),
    );
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
      //     floatingActionButton: FloatingActionButton(
      //     elevation: 0.0,
      //     child:  const Icon(Icons.add),
      //     // backgroundColor: const Color(0xFFE57373),
      //     onPressed: _goToInsert
      // ),
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
        _includiConfermato(context),
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





  Widget _buildChildRow(BuildContext context, OrdineExt ordine, int position){

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
                  onTap: ()=> _goToDetail(ordine),
                  child: ListTile(
                    trailing: Icon(Icons.chevron_right),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("# ${ordine.numero} "),
                        // Text(utentiList![index].toJson().toString()),


                        // Text(utentiList![index].toJson().toString()),
                        Text(ordine.pvenditaDenominazione??'',style: TextStyle(fontWeight: FontWeight.w800,fontSize: 16)),
                        Text("Effettuato il : ${AppUtils.formPostgresStringDate(ordine.createdAt?.substring(0,10)?? '')}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                        Text("€ ${ordine.total}"),
                        Text("Stato : ${ordine.statoCodice?? ''}",style: TextStyle(fontWeight: FontWeight.w600)),
                        Text("Consegna per il : ${AppUtils.formPostgresStringDate(ordine.dtConsegna.toString().substring(0,10)?? '')}"),
                      ],
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


  void _goToDetail(Ordine data){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new CarrelloDettaglioAdminScreen(ordine: data,puntoVendita: null,))).then((value) => _refresh());
  }

  void _goToInsert(){
    // Navigator.push(context,  MaterialPageRoute(
    //     builder: (context) =>
    //     new ProdottiCrud(ordine: null ))).then((value) => _refresh());
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
              icon: Icon(Icons.close), onPressed: () => onSearchButtonClear())),
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

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }
}
