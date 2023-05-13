import 'package:bufalabuona/data/categorie_prodotti_rest_service.dart';
import 'package:bufalabuona/data/prodotti_rest_service.dart';
import 'package:bufalabuona/data/unimis_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/categoria_prodotto.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../main.dart';
import '../../model/prodotto.dart';
import '../../model/unimis.dart';
import '../../utils/app_utils.dart';
import '../../utils/ensure_visibility_textformfield.dart';
import '../../utils/menu_choice.dart';
import 'package:flutter_blurhash/flutter_blurhash.dart';

class ProdottiCrud extends StatefulWidget {
  final Prodotto? prodotto;
  ProdottiCrud({this.prodotto});

  @override
  State<StatefulWidget> createState() => new _ProdottiCrudState();
}

class _ProdottiCrudState extends State<ProdottiCrud> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  FocusNode _focusNodeDenominazioneController=new FocusNode();
  FocusNode _focusNodeDescrizioneController = new FocusNode();
  FocusNode _focusNodeUnimisController = new FocusNode();
  FocusNode _focusNodeQuantitaController = new FocusNode();
  FocusNode _focusNodeCodiceController = new FocusNode();
  FocusNode _focusNodeDtFinValController = new FocusNode();
  FocusNode _focusNodeDtInserimentoController = new FocusNode();

  var now = new DateTime.now();

  ScrollController? _scroll;
  FocusNode _focus = new FocusNode();
  Prodotto? _prodottoSelected;

  TextEditingController? _denominazioneController;
  TextEditingController? _descrizioneController;
  TextEditingController? _unimisController;
  TextEditingController? _quantitaController;
  TextEditingController? _codiceController;
  TextEditingController? _dtFinValController;
  TextEditingController? _dtInserimentoController;
  TextEditingController? _catProdottoController;

  Prodotto? _prodotto;

  String? _denominazione;
  String? _descrizione;
  String? _unimis;
  String? _quantita;
  String? _codice;
  String? _dtFinVal;
  String? _catId;

  List<Unimis>? _listUnimis;
  MenuChoice? _unimisChoice;
  List<MenuChoice> _listUnimisMenuChoice = [];
  List<DropdownMenuItem<MenuChoice>> _unimisItems = [];

  List<CategoriaProdotto>? _listCatProdotto;

  MenuChoice? _categoriaProdotto;
  List<MenuChoice> _listCatMenuChoice = [];
  List<DropdownMenuItem<MenuChoice>> _categorieProdottiItems = [];

  bool _isAbilitato = true;
  bool _isLoading = false;
  bool _updateMode = false;

  String imageUrl='https://stiyidpiphnxmmtmfutn.supabase.co/storage/v1/object/public/public-images/no_picture.png';


  @override
  void initState() {
    super.initState();

    if (this.widget.prodotto != null) {
      _prodotto = this.widget.prodotto;
      _updateMode = true;
    } else {
      _prodotto = new Prodotto();
    }


    retrieveImage();

    init();
  }


  retrieveImage() async {
    final List<FileObject> object = await supabase
        .storage
        .from('public-images')
        .list();
    object.length;

    // var existingItem = object.firstWhere((itemToCheck) => itemToCheck.name.split('.')[0] == _prodotto!.codice!.toUpperCase(), orElse: () => null);

    if (object.any((val) => val.name.split('.')[0] == _prodotto!.codice?.toUpperCase())) {
     setState((){
       imageUrl = supabase
         .storage
         .from('public-images')
         .getPublicUrl('${_prodotto!.codice}.png');});
    }

  }


  init() async {

    _scroll = new ScrollController();
    _focus.addListener(() {
      _scroll!.jumpTo(-1.0);
    });

    await _loadCategorieProdotti();

    await _initCategorieProdottoList();
    await _loadUnimis();
    await _initUnimisList();
    initCrud();
    await _initCategoriaProdottiCrud();
    await _initUnimisCrud();
   }




  void initCrud(){

    _denominazioneController =  new TextEditingController(text: _prodotto?.denominazione ?? '');
    _descrizioneController = new TextEditingController(text: _prodotto?.descrizione ?? '');
    _unimisController = new TextEditingController(text: _prodotto?.unimisCodice ?? '');
    _quantitaController = new TextEditingController(text: _prodotto?.quantita.toString() ?? '');
    _codiceController = new TextEditingController(text: _prodotto?.codice ?? '');
    _dtFinValController = new TextEditingController(text: _prodotto?.dtFinVal ?? '');
    _dtInserimentoController = new TextEditingController(text: _prodotto?.dtInserimento ?? '');
    _catProdottoController = new TextEditingController(text: _prodotto?.catProdottoCodice ?? '');


    if (_prodotto?.dtFinVal != null) {
      _isAbilitato = false;
    }

  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Prodotto"),
          ),
          body: Container(
            child: SingleChildScrollView(
                controller: _scroll,
                child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        explainText(),
                        SizedBox(
                          height: 20,
                        ),
                        _sizedContainer(
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                        _isLoading
                            ? SizedBox(
                                height:
                                    MediaQuery.of(context).size.height / 1.3,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              )
                            : crudText(),
                      ],
                    ))),
          ),
          floatingActionButton: FloatingActionButton(
            elevation: 0.0,
            child: const Icon(Icons.save_rounded),
            // backgroundColor: const Color(0xFFE57373),
            onPressed: _validateInputs,
          )),
    );
  }

  Widget explainText() {
    return Column(
      children: const <Widget>[
        Text("Inserisci o modifica Prodotto",
            style: TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget crudText() {
    return Row(children: [
      Expanded(
          child: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          EnsureVisibleWhenFocused(
              focusNode: _focusNodeCodiceController,
              child: TextFormField(
                decoration:  InputDecoration(
                  labelText: "Codice",
                  labelStyle: TextStyle(
                    color: Colors.green[900],
                    fontSize: 18.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _codiceController,
                focusNode: _focusNodeCodiceController,
                validator: _validateNome,
                onSaved: (val) => _codice = val,
              )),
          EnsureVisibleWhenFocused(
              focusNode: _focusNodeDenominazioneController,
              child: TextFormField(
                decoration:  InputDecoration(
                  labelText: "Denominazione",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                      color: Colors.green[900]
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _denominazioneController,
                focusNode: _focusNodeDenominazioneController,
                validator: _validateNome,
                onSaved: (val) => _denominazione = val,
              )),
          EnsureVisibleWhenFocused(
              focusNode: _focusNodeDescrizioneController,
              child: TextFormField(
                decoration:  InputDecoration(
                  labelText: "Descrizione",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green[900]
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _descrizioneController,
                focusNode: _focusNodeDescrizioneController,
                validator: _validateNome,
                onSaved: (val) => _descrizione = val,
              )),
          new Padding(padding: new EdgeInsets.all(5.0)),
          InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: "Unità di misura",
              labelStyle: TextStyle(color:Colors.green.shade900,fontSize: 18),
            ),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<MenuChoice>(
                  hint: Text('Seleziona'),
                  value: _unimisChoice,
                  items: _unimisItems, //loadDerogaItems(),
                  onChanged: onChangeUnimis,
                )),
          ),
          // EnsureVisibleWhenFocused(
          //     focusNode: _focusNodeUnimisController,
          //     child: TextFormField(
          //       decoration: const InputDecoration(
          //         labelText: "Unita di misura",
          //         labelStyle: TextStyle(
          //           fontSize: 18.0,
          //         ),
          //       ),
          //       keyboardType: TextInputType.text,
          //       controller: _unimisController,
          //       focusNode: _focusNodeUnimisController,
          //       validator: _validateIndirizzo,
          //       onSaved: (val) => _unimis = val,
          //     )),
          // new Padding(padding: new EdgeInsets.all(5.0)),
          InputDecorator(
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: "Categoria",
              labelStyle: TextStyle(color:Colors.green.shade900,fontSize: 18),
            ),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<MenuChoice>(
                  hint: Text('Seleziona'),
                  value: _categoriaProdotto,
                  items: _categorieProdottiItems, //loadDerogaItems(),
                  onChanged: onChangeCategoriaProdotto,
                )),
          ),
          // new Padding(padding: new EdgeInsets.all(5.0)),
          //
          // EnsureVisibleWhenFocused(
          //     focusNode: _focusNodeQuantitaController,
          //     child: TextFormField(
          //       decoration:  InputDecoration(
          //         labelText: "Quantita",
          //         labelStyle: TextStyle(
          //           color: Colors.green[900],
          //           fontSize: 18.0,
          //         ),
          //       ),
          //       keyboardType: TextInputType.text,
          //       controller: _quantitaController,
          //       focusNode: _focusNodeQuantitaController,
          //       validator: _validateNome,
          //       onSaved: (val) => _quantita = val,
          //     )),
          // new Padding(padding: new EdgeInsets.all(5.0)),
          Padding(padding: EdgeInsets.all(5.0)),

          Row(
            children: [
              Expanded(child: Text("Abilitato",style: TextStyle( color: Colors.green[900]),)),
              Switch(
                value: _isAbilitato,
                onChanged: (bool value) {
                  setState(() {
                    _isAbilitato = value;
                  });
                },
              ),
            ],
          ),
        ]),
      ))
    ]);
  }

  String? _validateNome(String? value) {
    if (value!.isEmpty) {
      return "Campo obbligatorio";
    }
  }

  String? _validateIndirizzo(String? value) {
    if (value!.isEmpty) {
      return "Campo Obbligatorio";
    }
    return null;
  }


  void _validateInputs() {
    final form = _formKey.currentState!;
    bool valid=true;


    if (form.validate()) {
      form.save();

      if(_unimisChoice==null){
        valid=false;
        showMessage("Selezionare una unità di misura");
        return;
      }

      if(valid){
        _prodotto!.unimisCodice = _unimisChoice!.key;
        _prodotto!.denominazione = _denominazione!.toUpperCase();
        _prodotto!.descrizione = _descrizione!.toLowerCase();
        _prodotto!.codice = _codice!.toUpperCase();
        _prodotto!.quantita = 1;
        if(_categoriaProdotto!=null){
          _prodotto!.catProdottoCodice = _categoriaProdotto!.key;
        }
        _onSaveProdotto(context, _prodotto!);
      }
    }
  }

  Future _onSaveProdotto(
      BuildContext context, Prodotto prodotto) async {
    WSResponse? resp;
    bool update = false;
    setState(() {
      _isLoading = true;
    });
    if (prodotto.prodId == null) {
      resp = await ProdottiRestService.internal(context).insertProdotto(prodotto);
    } else {
      resp = await ProdottiRestService.internal(context).updateProdotto(prodotto);
    }
    setState(() {
      _isLoading = false;
    });
    updateDialog(context, resp);
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  Future<void> updateDialog(BuildContext context, WSResponse? resp) async {
    String message = "Operazione avvenuta con successo";
    if (resp != null && resp.errors != null) {
      if(resp.status!=null){
      message = AppUtils.decodeHttpStatus(resp.status);}else{
        message=resp.errors!.first.message!;
      }
    }
    String title = "Attenzione";
    if(resp!.success !=null){
      title ="Complimenti";
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
    Navigator.pop(context,true);
  }

  Widget _sizedContainer(Widget child) {
    return SizedBox(
      width: 300.0,
      height: 150.0,
      child: Center(child: child),
    );
  }

  ///GESTIONE CATEGORIE PRODOTTI

  _initCategoriaProdottiCrud() async {
    setState((){
      _catProdottoController = new TextEditingController();
      if (_prodotto!=null && _prodotto?.catProdottoCodice != null && _listCatMenuChoice.isNotEmpty) {
        _categoriaProdotto = _listCatMenuChoice.firstWhere((element) {
          return element.key == _prodotto?.catProdottoCodice;
        });
        onChangeCategoriaProdotto(_categoriaProdotto);
      }});
  }

  Future<void> _initCategorieProdottoList() async {
    _listCatProdotto?.forEach((element) {
      MenuChoice e = new MenuChoice(element.codice, element.descrizione?.toUpperCase());
      setState(() {
        _listCatMenuChoice.add(e);
        _categorieProdottiItems.add(DropdownMenuItem(value: e, child: new Text(e.value!)));
      });
    });

  }

  Future<void> _loadCategorieProdotti() async{
    WSResponse resp  = await CategorieProdottiRestService.internal(context).getAll();
    if(resp.success!){
      setState((){
        _listCatProdotto = CategorieProdottiRestService.internal(context).parseList(resp.data!.toList());
      });
    }
  }

  void onChangeCategoriaProdotto(MenuChoice? selected) {
    setState(() {
      _categoriaProdotto = selected;
      _catProdottoController!.text = _categoriaProdotto!.key!;
    });
  }

  ///GESTIONE UNIMIS

  _initUnimisCrud() async {
    setState((){
      _unimisController = new TextEditingController();
      if (_prodotto!=null && _prodotto?.unimisCodice != null && _listUnimisMenuChoice.isNotEmpty) {
        _unimisChoice = _listUnimisMenuChoice.firstWhere((element) {
          return element.key == _prodotto?.unimisCodice;
        });
        onChangeUnimis(_unimisChoice);
      }});
  }

  Future<void> _initUnimisList() async {
    _listUnimis?.forEach((element) {
      MenuChoice e = new MenuChoice(element.codice, element.descrizione?.toUpperCase());
      setState(() {
        _listUnimisMenuChoice.add(e);
        _unimisItems.add(DropdownMenuItem(value: e, child: new Text(e.value!)));
      });
    });

  }

  Future<void> _loadUnimis() async{
    WSResponse resp  = await UnimisRestService.internal(context).getAll();
    if(resp.success!){
      setState((){
        _listUnimis = UnimisRestService.internal(context).parseList(resp.data!.toList());
      });
    }
  }

  void onChangeUnimis(MenuChoice? selected) {
    setState(() {
      _unimisChoice = selected;
      _unimisController!.text = _unimisChoice!.key!;
    });
  }


}
