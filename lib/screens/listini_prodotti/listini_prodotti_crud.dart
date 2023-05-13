import 'package:bufalabuona/data/categorie_rest_service.dart';
import 'package:bufalabuona/data/listini_prodotti_rest_service.dart';
import 'package:bufalabuona/data/prodotti_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/listino_prodotti.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/prodotto.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/listini/listini_crud.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:bufalabuona/utils/menu_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:rotated_corner_decoration/rotated_corner_decoration.dart';

import '../../utils/ensure_visibility_textformfield.dart';

class ListiniProdottiCrud extends ConsumerStatefulWidget {
  final Listino? listino;
  final List<ListinoProdottiExt>? listinoProdotti;
  final bool? updateMode;

  const ListiniProdottiCrud({this.listino, this.listinoProdotti,@required this.updateMode});

  @override
  ConsumerState<ListiniProdottiCrud> createState() => _ListiniProdottiCrudState();
}

class _ListiniProdottiCrudState extends ConsumerState<ListiniProdottiCrud> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();

  Listino? _listino;
  List<ListinoProdottiExt>? _values;
  List<Prodotto> _listProdotti = [];
  List<Prodotto> _filteredValues = [];
  bool _isLoading = true;
  Map<int,num> _listPrezzi = new Map();
  Map<int,TextEditingController> _listTextEditingController = new Map();
  bool _updateMode = false;

  List<Categoria>? _listaCategorie =[];

  TextEditingController? _listDescrizioneController;
  TextEditingController? _dtFinValController;
  TextEditingController? _dtIniValController;

  String? _listDescrizione;
  String? _dtFinVal;
  String? _dtIniVal;
  int? catId;


  TextEditingController? _catIdController;
  MenuChoice? _categoria;
  List<MenuChoice> _listMenuChoice = [];
  List<DropdownMenuItem<MenuChoice>> _categorieItems = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    init();
  }


  void init() async{
    setState((){
      _listino = this.widget.listino;

      _values = this.widget.listinoProdotti;

      _updateMode = this.widget.updateMode ?? false;
    });

    await _loadCategorie();
    await _readProdotti();
    if(_updateMode){
      //abbiamo letto i prodotti vendibili, adesso per quelli presenti settiamo il prezzo
      await _setProdotti(_values);
    }
    await _initCategorieList();
    await _initCategoriaCrud();
    await _initTextEditingController();


    setState(() {
      _isLoading=false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_listino?.descrizione ?? 'Nuovo Listino'),
      ),
      resizeToAvoidBottomInset: false,
      body: WillPopScope(onWillPop: null, child: stackWidget()),
      floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child: const Icon(Icons.save),
          // backgroundColor: const Color(0xFFE57373),
          onPressed: _onSave),
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
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Expanded(
          child: Column(
        children: [
          listinoCard(),
          Flexible(child:  _createList(context)),
        ],
      )),
    );
  }

  Widget _createList(BuildContext context) {

    if (_isLoading) {
      return AppUtils.loader(context);
    }
    if (this._filteredValues.isEmpty) {
      return AppUtils.emptyList(context, FontAwesomeIcons.userSlash);
    }
    var list = ListView.builder(
        itemCount: _filteredValues.length,
        itemBuilder: (context, position) {
          return _buildChildRow(context, _filteredValues[position], position);
        });


    return RefreshIndicator(
      child: list,
      onRefresh: _refresh,
      strokeWidth: 3,
    );
  }

  Widget _buildChildRow(BuildContext context, Prodotto prod, int position) {

    bool active = false;

    if(_listTextEditingController[prod.prodId]!.text != '0'){
        active=true;
    }
    if(_values==null){
      active=true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Card(
                color: active ?Colors.green[100] : Colors.white60,
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5),
                elevation: 1.0,
                child: InkWell(
                  // onTap: ()=> _goToEdit(listini),
                  child: Container(
                    foregroundDecoration:(!active) ?
                    const RotatedCornerDecoration.withColor(color: Colors.black54,  badgeSize: Size(64, 64),
                        badgeCornerRadius: Radius.circular(8),
                        badgePosition: BadgePosition.topEnd)

                    // RotatedCornerDecoration(
                    //   color: Colors.black54,
                    //   geometry:  BadgeGeometry(width: 12, height: 2000,cornerRadius: 12),
                    //   // textSpan: const TextSpan(
                    //   //   text: 'NON\nATTIVO',
                    //   //   style: TextStyle(fontSize: 11,color: Colors.white),
                    //   // ),
                    // )
                        :null,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prod.denominazione!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              prod.descrizione!,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            Text("${prod.quantita} ${prod.unimisCodice} "),
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: "Inserire o Modificare Prezzo ",
                                labelStyle: TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              controller: _listTextEditingController[prod.prodId],
                              validator: _validatePrezzo,
                              keyboardType: TextInputType.text,
                              style: TextStyle(fontSize: 33, color: Colors.black),
                              // onSaved: (val) => _listPrezzi[position] = num.parse(val ?? '0'),
                            ),
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

  String? _validatePrezzo(String? value) {

    if (value!.isEmpty) {
      return "campo obbligatorio";
    }else{
      value = value.replaceAll(",", ".");
      if(double.tryParse(value)==null){
        return "inserire un valore valido";
      }
    }

    return null;
  }

  Future<void> _readProdotti() async {
    WSResponse resp = await ProdottiRestService.internal(context).getAll();
    if (resp != null && resp.success!) {
      setState(() {
        _listProdotti = ProdottiRestService.internal(context).parseList(resp.data!.toList());
        _filteredValues.addAll(_listProdotti);
        _listProdotti.forEach((element) {
          _listPrezzi[element.prodId!]=0;
        });
      });
    }
  }

  ///siamo in modifica, quindi all'elenco dei prodotti generali,
  ///dobbiamo appendere il prezzo prestabilito, inoltre dobbiamo ordinare _listProdotti
  /// così da mettere i valori 0 in fondo.
  _setProdotti(List<ListinoProdottiExt>? listino) async{
    _values!.forEach((element) {
      _listPrezzi[element.prodId!]=element.price!;
    });
    // _values!.forEach((element) { _listProdotti.sort((a,b)=>b.prodId!.compareTo(element.prodId!));});
  }

  _initTextEditingController() async{
    _listProdotti.forEach((element) {
      TextEditingController t =  TextEditingController(text: _listPrezzi[element.prodId].toString());
      setState(() {
        _listTextEditingController[element.prodId!]=t; });
    });
  }

   _initCategoriaCrud() async {
    setState((){
    _catIdController = new TextEditingController();
    _listDescrizioneController = new TextEditingController(text: _listino?.descrizione ?? '');
    _dtFinValController = new TextEditingController(text: _listino?.dtFinVal.toString() ?? '');
    _dtIniValController = new TextEditingController(text: _listino?.dtIniVal.toString() ?? '');
    if (_listino!=null && _listino?.catId != null && _listMenuChoice.isNotEmpty) {
      _categoria = _listMenuChoice.firstWhere((element) {
        return element.key == _listino?.catId.toString();
      });
      onChangeCategoria(_categoria);
    }});
  }

  Future<void> _initCategorieList() async {

      _listaCategorie?.forEach((element) {
        MenuChoice e = new MenuChoice(element.id.toString(), element.descrizione);
        setState(() {
        _listMenuChoice.add(e);
        _categorieItems.add(DropdownMenuItem(value: e, child: new Text(e.value!)));
      });
    });

  }

  Future<void> _loadCategorie() async{
    WSResponse resp  = await CategorieRestService.internal(context).getAll();
    if(resp.success!){
      setState((){
        _listaCategorie = CategorieRestService.internal(context).parseList(resp.data!.toList());
      });
    }
  }

  void onChangeCategoria(MenuChoice? selected) {
    setState(() {
      _categoria = selected;
      _catIdController!.text = _categoria!.key!;
    });
  }





  _onSave() async{
    setState(() {
      _isLoading=true;
    });
    List<ListinoProdotti> _listToUpdate = [];
    List<ListinoProdotti> _listToInsert = [];
    List<ListinoProdotti> _listToDelete = [];
    _prepareToSave(_listToUpdate, _listToInsert,_listToDelete);
    List<WSResponse> respList = [];
    if(_listToUpdate.isNotEmpty){
      WSResponse respUpdate = await ListiniProdottiRestService.internal(context).upsertMassiveListinoProdotti(_listToUpdate);
      respList.add(respUpdate);
    }
    if(_listToInsert.isNotEmpty){
      WSResponse respInsert = await ListiniProdottiRestService.internal(context).upsertMassiveListinoProdotti(_listToInsert);
      respList.add(respInsert);
    }
    if(_listToDelete.isNotEmpty){
      WSResponse respDelete = await ListiniProdottiRestService.internal(context).deleteMassiveListinoProdotti(_listToDelete);
      respList.add(respDelete);
    }


    // if(_listToUpdate.isNotEmpty && _listToInsert.isNotEmpty && _listToDelete.isNotEmpty){
    //   WSResponse respInsert = await ListiniProdottiRestService.internal(context).upsertMassiveListinoProdotti(_listToInsert);
    //   WSResponse respUpdate = await ListiniProdottiRestService.internal(context).upsertMassiveListinoProdotti(_listToUpdate);
    //   respList.add(respUpdate);
    //   respList.add(respInsert);
    // }else{
    //   if(_listToUpdate.isNotEmpty){
    //     WSResponse resp = await ListiniProdottiRestService.internal(context).upsertMassiveListinoProdotti(_listToUpdate);
    //     respList.add(resp);
    //   }else{
    //     WSResponse resp = await ListiniProdottiRestService.internal(context).upsertMassiveListinoProdotti(_listToInsert);
    //     respList.add(resp);
    //   }
    // }
    setState((){
      _isLoading=false;
    });

    respList.forEach((resp) {
    if(resp.success!=null && resp.success!){
      debugPrint("figo, tutto bene");
    }else{
      debugPrint("e no ciccio!");
    }
    updateDialog(context,resp);
    });
  }

  Future<void> updateDialog(BuildContext context, WSResponse? resp) async {
    String message = "Operazione avvenuta con successo";
    if (resp != null && resp.errors != null) {
      message = AppUtils.decodeHttpStatus(resp.status);
    }
    String title = "Attenzione";
    if(resp!.success!=null && resp.success!)  {
      title ="Complimenti";
    }
    if(resp.errors!=null){
      message = resp.errors![0].message!;
    }
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
        content: Text(message),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("OK")),
        ],
      ),
    );
    if(resp.success!=null && resp.success!) {
      Navigator.pop(context,true);
    }
  }

  _prepareToSave( List<ListinoProdotti> _listToUpdate , List<ListinoProdotti> _listToInsert, List<ListinoProdotti> _listToDelete){

    _listPrezzi.forEach((key, value) {

      var price= num.parse(_listTextEditingController[key]!.text.replaceAll(',', '.'));
      if(price != value){
        debugPrint("è cambiato il prezzo del prodId = $key");
        if(_values!=null && _values!.isNotEmpty){
          if(_values!.any((item) => item.prodId == key)){
            ListinoProdottiExt? p=_values?.firstWhere((element) => element.prodId == key);
            ListinoProdotti toUpdate = new ListinoProdotti();
            if(p!=null && p.sku!=null){
              toUpdate.sku = p.sku;
              toUpdate.prodId = p.prodId;
              toUpdate.price = price;
              toUpdate.listId = p.listId;
              if(price==0){
                _listToDelete.add(toUpdate);
              }else{
              _listToUpdate.add(toUpdate);
              }
            }
          }else{
            ListinoProdotti toInsert = new ListinoProdotti();
            toInsert.listId = _listino!.id;
            toInsert.price = price;
            toInsert.prodId = key;
            /// sku deve essere generato
            _listToInsert.add(toInsert);
          }
        }else{
          ListinoProdotti toInsert = new ListinoProdotti();
          toInsert.listId = _listino!.id;
          toInsert.price = price;
          toInsert.prodId = key;
          /// sku deve essere generato
          _listToInsert.add(toInsert);
        }
      }
    });
    debugPrint("TOT aggiornare ${_listToUpdate.length}\n TOT inserire ${_listToInsert.length}\n TOT cancellare ${_listToDelete.length}");
  }


  Future<void> _refresh() async {
    _filteredValues.clear();
    _listProdotti.clear();
    _readProdotti();
  }

  Widget listinoCard(){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Card(margin: EdgeInsets.all(0.0),
          color: Color(0xFFF1E6FF),
          elevation:  3.0,
          child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(FontAwesomeIcons.clipboardList,size: 44,),
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Valido dal ${_listino!.dtIniVal?? ''} al ${_listino!.dtFinVal ?? ''}"),
                  Text(_listino!.descrizione?? '',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22)),
                  Text("Categoria ${_categoria?.value ?? ''}"),
                ],
              ),
            )),
            IconButton(onPressed: _editListinoInformation, icon: Icon(FontAwesomeIcons.pencil))
          ]
          )),
    );
  }

  void _editListinoInformation() {
    Navigator.push(context,  MaterialPageRoute(
        builder: (context) =>
        new ListiniCrud(listino: _listino, updateMode: true,))).then((value) => _refresh());

  }


  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message,style: TextStyle(color: Colors.red,fontSize: 16)));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }
}
