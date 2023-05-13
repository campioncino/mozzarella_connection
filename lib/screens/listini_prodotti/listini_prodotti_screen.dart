import 'package:bufalabuona/data/listini_prodotti_rest_service.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/listino_prodotti.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

class ListiniCrud extends StatefulWidget {
  final Listino? listino;
  const ListiniCrud({this.listino});

  @override
  State<ListiniCrud> createState() => _ListiniCrudState();
}

class _ListiniCrudState extends State<ListiniCrud> {
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
  }


  @override
  Widget build(BuildContext context) {
    return  ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_listino?.descrizione ?? 'Nuovo Listino'),
        ),
        resizeToAvoidBottomInset: false,
        body: WillPopScope(
            onWillPop: null,
            child: stackWidget()),

        // floatingActionButton: FloatingActionButton(
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
      return AppUtils.emptyList(context,FontAwesomeIcons.userSlash);
    }
    var list = ListView.builder(
        itemCount: _filteredValues.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _filteredValues[position], position);
        });

    return RefreshIndicator(child: list, onRefresh: _refresh,strokeWidth: 3,);
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
                    foregroundDecoration:(listini.price==null || listini.price==0) ? const RotatedCornerDecoration(
                      color: Colors.red,
                      geometry: const BadgeGeometry(width: 34, height: 34,cornerRadius: 12),
                      // textSpan: const TextSpan(
                      //   text: 'NON\nATTIVO',
                      //   style: TextStyle(fontSize: 11,color: Colors.white),
                      // ),
                    ) : null,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            Text(listini.prodDescrzione!,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
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
}
