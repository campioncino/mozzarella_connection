import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../data/categorie_prodotti_rest_service.dart';
import '../../model/categoria_prodotto.dart';
import 'categorie_prodotti_crud.dart';


class CategorieProdottiScreen extends StatefulWidget {
  const CategorieProdottiScreen({Key? key}) : super(key: key);

  @override
  State<CategorieProdottiScreen> createState() => _CategorieProdottiScreenState();
}

class _CategorieProdottiScreenState extends State<CategorieProdottiScreen> {
  var dateFormatter = new DateFormat('dd-mm-yyyy');
  List<PuntoVendita>? puntiVenditaList;
  Categoria? _cat;
  bool _isLoading = true;

  final GlobalKey<ScaffoldState> _refreshKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  final TextEditingController _searchController = new TextEditingController();

  List<CategoriaProdotto>? _values ;
  List<CategoriaProdotto> _filteredValues = [];

  _CategorieProdottiScreenState() {
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
        List<CategoriaProdotto> list = _values!.where((v) {
          return v.descrizione!.contains(text.toUpperCase());
        }).toList();
        _filteredValues.clear();
        _filteredValues.addAll(list);
      }
    });
  }

  readData() async {
    WSResponse? resp = await CategorieProdottiRestService.internal(context).getAll();
    if(resp!=null && resp.success!){
      setState((){
        _values = CategorieProdottiRestService.internal(context).parseList(resp.data!.toList());
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
    // await readPuntiVendita();
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
          child:  const Icon(Icons.add),
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
      return AppUtils.emptyList(context,FontAwesomeIcons.typo3);
    }
    var list = ListView.builder(
        itemCount: _filteredValues.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _filteredValues[position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }


  Widget _buildChildRow(BuildContext context, CategoriaProdotto listini, int position){
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
                  onTap: ()=> _goToDetail(listini),
                  child: Container(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 7),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(utentiList![index].toJson().toString()),
                          Text("Codice : ${listini.codice!}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                          Text("Descrizione : ${listini.descrizione!}",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
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

  void _goToDetail(CategoriaProdotto data){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new CategorieProdottiCrud(updateMode: true,categoria: data,))).then((value) => _refresh());
  }

  void _goToEdit(CategoriaProdotto data){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new CategorieProdottiCrud())).then((value) => _refresh());
  }

  _goToInsert(){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new CategorieProdottiCrud(categoria: null,updateMode: false, categorieList: _values,))).then((value) => _refresh());

  }


  Future<void> _refresh() async{
    _filteredValues.clear();
    _values!.clear();
    readData();

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
      WidgetsBinding.instance.addPostFrameCallback((_) => _searchController.clear());
    });
  }
}
