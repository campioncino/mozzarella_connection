import 'dart:async';

import 'package:bufalabuona/model/prodotto.dart';
import 'package:bufalabuona/screens/prodotti/prodotti_crud.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/ui_icons.dart';


class LovProdottiFragment extends StatefulWidget {
  final String appbarTitle;
  final Function onSearch;
  final bool showInsert;
  final Color? styleColor;


  const LovProdottiFragment(
      {required this.appbarTitle,
        required this.onSearch,
        this.showInsert: false,
        this.styleColor});

  @override
  _LovProdottiFragmentState createState() =>  _LovProdottiFragmentState();
}

class _LovProdottiFragmentState extends State<LovProdottiFragment> {
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.blueGrey,
  );

  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = new TextEditingController();

  List<Prodotto>? _values = [];
  List<Prodotto> _filteredValues = [];

  _LovProdottiFragmentState() {
    _searchController.addListener(() {
      handleSearch(_searchController.text);
    });
  }

  Color? _styleColor;

  @override
  void initState() {
    super.initState();
    initValues();
    init();

  }

  Future<List<Prodotto>> initValues() async{
    List<Prodotto> resp = await this.widget.onSearch();
    return resp;
  }

  Future init() async {
    _filteredValues.clear();
    _values = await this.widget.onSearch();
    setState(() {
      _filteredValues.addAll(_values!);
      if (this.widget.styleColor != null) {
        _styleColor = this.widget.styleColor;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void handleSearch(String text) {
    setState(() {
      if (text.isEmpty) {
        _filteredValues.clear();
        _filteredValues.addAll(_values!);
      } else {
        List<Prodotto> list = _values!.where((v) {
          return v.descrizione!.contains(text.toUpperCase());
              // || v.catId!.contains(text.toUpperCase());
        }).toList();
        _filteredValues.clear();
        _filteredValues.addAll(list);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
      appBar: new AppBar(
        elevation: 0.0,
        title: new Text(this.widget.appbarTitle),
        backgroundColor: _styleColor,
//        actions: _actions(),
      ),
      body: new Column(
        children: <Widget>[
          _buildSearchBar(context),
          new Expanded(child: Center(child: _createListView(context))),
        ],
      ),
      floatingActionButton: this.widget.showInsert
          ? new FloatingActionButton(
        elevation: 0.0,
        child:Icon(UiIcons.plusIco),
        onPressed: _editProdotti,
      )
          : new Container(
        height: 0.0,
      ), //        body: Scaffold(appBar: buildBar(context), body: Center(child: futureBuilder))
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    TextField searchField = new TextField(
      style: TextStyle(fontSize: 20.0,
        // color: Colors.black
      ),
      controller: _searchController,
      decoration: new InputDecoration(
//          contentPadding: EdgeInsets.all(5.0),
          border: InputBorder.none,
          hintText:"Nome Punto Vendita",
          suffixIcon: IconButton(
              icon: UiIcons.close, onPressed: () => onSearchButtonClear())),
    );

    return new Card(
        elevation: 6.0,
        margin: EdgeInsets.all(10.0),
        child: new Padding(
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

  Widget _emptyBody() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Icon(
            Icons.account_circle,
            size: 50.0,
            color: Colors.grey[300],
          ),
          new SizedBox(height: 20.0),
           Text("Nessun risultato",
            style: new TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _createListView(BuildContext context) {
    if (_filteredValues.isEmpty) {
      return _emptyBody();
    }
    return new ListView.builder(
        itemCount: _filteredValues.length,
        itemBuilder: (context, position) {
          return _buildItem(context, _filteredValues[position], position);
        });
  }

  Widget _buildItem(BuildContext context, dynamic value, int position) {
    var value = _filteredValues[position];
    return _buildListRow(context, value, position);
  }

  void _onTapItem(BuildContext context, dynamic p) {
    Navigator.pop(context, p);
  }

  Widget row(Prodotto p, int position) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                p.prodId.toString(),
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                p.descrizione?.trim() ?? '',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                p.codice?.trim().toLowerCase() ?? '',
                style: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              Text("${p.quantita} ${p.unimisCodice}",
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ],
          ),
        ),
        // _buttons(p, position),
      ],
    );
  }

  _buttons(Prodotto p, int position) {
    if (p.dtFinVal != null) {
      return new Container();
    }
    return Row(children: <Widget>[
      IconButton(
        icon: new Icon(
          FontAwesomeIcons.penToSquare,
          size: 20.0,
        ),
        onPressed: () => _editProdotti(prodotti: p),
      ),
      IconButton(
          icon: new Icon(
            FontAwesomeIcons.deleteLeft,
            size: 20.0,
          ),
          onPressed: () => _deleteProdotti(context, p, position)),
    ]);
  }

  Widget _buildListRow(BuildContext context, dynamic value, int position) {
    return InkWell(
        onTap: () => _onTapItem(context, value),
        child: new Column(children: <Widget>[
          Divider(height: 0.0),
          Padding(padding: EdgeInsets.all(15.0), child: row(value, position)),
          new Container(
            height: 5.0,
          )
        ]));
  }

  void _editProdotti({Prodotto? prodotti}) async {
    Prodotto? p = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProdottiCrud(prodotto: prodotti)),
    );

    if (p != null) {
      showDialog(
          context: context,
          builder: (BuildContext context) => new AlertDialog(
            content: new Text("Punto Vendita Inserito"),
            actions: <Widget>[
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                        ),
                        child:
                        Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        })
                  ])
            ],
          ));
      init();
    }
  }

  void _deleteProdotti(BuildContext context, Prodotto p, int position) async {
    // ProdottiService.internal(context).deleteProdotti(p).then((result) {
    //   setState(() {
    //     if (result > 0) {
    //       _values!.remove(p);
    //     }
    //   });
    // });
    init();
  }
}
