import 'package:bufalabuona/data/listini_prodotti_rest_service.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/listino_prodotti.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/listini_prodotti/listini_prodotti_crud.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../../utils/ui_icons.dart';

class ListiniProdottiScreen extends StatefulWidget {
  final Listino? listino;
  final bool lovMode;
  const ListiniProdottiScreen({this.listino,required this.lovMode});


  @override
  State<ListiniProdottiScreen> createState() => _ListiniProdottiScreenState();
}

class _ListiniProdottiScreenState extends State<ListiniProdottiScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  List<ListinoProdottiExt>? _values ;
  List<ListinoProdottiExt> _filteredValues = [];
  Listino? _listino;
  bool _isLoading=true;

  @override
  void initState() {
    super.initState();
    _listino = this.widget.listino;
    _filteredValues.clear();
    init();
  }


  void init() async {
      await readData(_listino);
      if(_values!.isEmpty){
        _goToProdottiCrud();
      }
  }

  _goToProdottiCrud(){
    Navigator.push(context, MaterialPageRoute( builder: (context) =>
    new ListiniProdottiCrud(listino: _listino,updateMode: false,))).then((value) => _refresh());

  }

  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_listino?.descrizione ?? 'Nuovo Listino'),
          actions: <Widget>[
            IconButton(
              icon: UiIcons.pencil,
              onPressed: () => _editListino(context,_listino),
            ),
          ],
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: null,
            child: stackWidget()),

        // floatingActionButton: FloatingActionButton(
        //     elevation: 0.0,
        //     child:  const Icon(UiIcons.addIco),
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
    return new Stack(children: listWidgets);
  }

  Widget body() {
    return Expanded(child: Column(
      children: [
        // _buildSearchBar(context),
        // SizedBox(height: 20),
        Flexible(child: _createList(context)),
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
        itemCount: _filteredValues.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _filteredValues[position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
  }


  Widget _buildChildRow(BuildContext context, ListinoProdottiExt listini, int position){
    listini;
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
                   onTap: ()=> _onTapItem(context,listini),
                  child: Container(
                    foregroundDecoration:(listini.price==null || listini.price==0) ? 
                    // const RotatedCornerDecoration(
                    //   color: Colors.red,
                    //   geometry:  BadgeGeometry(width: 34, height: 34,cornerRadius: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(listini.prodDenominazione!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                            Text(listini.prodDescrzione ?? ''),
                            Text("${listini.prodQuantita} ${listini.prodUnimisDescrizione} "),
                          ],
                        ),
                        trailing:  Text("${listini.price.toString()} €",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
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

  readData(_listino) async {
    WSResponse resp;

    if(_listino!=null) {
      resp = await ListiniProdottiRestService.internal(context)
          .getAllByListId(_listino.id);
    }else{
      resp = await ListiniProdottiRestService.internal(context)
          .getAll();
    }
    if(resp!=null && resp.success!){
      setState((){
        _values = ListiniProdottiRestService.internal(context).parseListExt(resp.data!.toList());
        _filteredValues.addAll(_values!);
        _filteredValues.sort((a, b) => b.price!.compareTo(a.price!));
        _isLoading=false;
      });
    }
    else{
      debugPrint("errore!!");
    }
  }

  Future<void> _refresh() async{
    _filteredValues.clear();
    _values!.clear();
    readData(_listino);
  }

  _editListino(BuildContext context, Listino? listino){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new ListiniProdottiCrud(listino: listino, listinoProdotti: _filteredValues,updateMode: true,))).then((value) => _refresh());

  }

  _goToInsert(){
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new ListiniProdottiCrud(listino: null, listinoProdotti: null,updateMode: false,))).then((value) => _refresh());

  }

  void _onTapItem(BuildContext context, ListinoProdotti p) {
    if (this.widget.lovMode) {
       debugPrint(p.toString());

      Navigator.pop(context, p);  }
    }

}
