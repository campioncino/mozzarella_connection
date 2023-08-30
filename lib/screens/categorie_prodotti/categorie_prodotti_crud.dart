import 'package:bufalabuona/data/categorie_rest_service.dart';
import 'package:bufalabuona/data/listini_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/categoria_prodotto.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:bufalabuona/utils/menu_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../data/categorie_prodotti_rest_service.dart';
import '../../utils/ui_icons.dart';

class CategorieProdottiCrud extends StatefulWidget {
  final CategoriaProdotto? categoria;
  final bool? updateMode;
  final List<CategoriaProdotto>? categorieList ;

  const CategorieProdottiCrud({this.categoria, @required this.updateMode,this.categorieList});

  @override
  State<CategorieProdottiCrud> createState() => _CategorieProdottiCrudState();
}

class _CategorieProdottiCrudState extends State<CategorieProdottiCrud> {
  final dateFormatter = new DateFormat('dd-MM-yyyy');

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();

  CategoriaProdotto? _categoria;
  bool _isLoading = false;
  bool _updateMode = false;

  TextEditingController? _catDescrizioneController;
  TextEditingController? _catCodiceController;

  String? _catDescrizione;
  String? _catCodice;



  List<CategoriaProdotto>? _categorieList;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    init();
  }


  void init() async{
    setState((){
      _categoria = this.widget.categoria;
      _updateMode = this.widget.updateMode!;
      _categorieList = this.widget.categorieList;
    });

    _catCodiceController = new TextEditingController(text: _categoria?.codice ?? '');
    _catDescrizioneController = new TextEditingController(text: _categoria?.descrizione ?? '');

    setState(() {
      _isLoading=false;
      if(!_updateMode){
        _categoria=new CategoriaProdotto();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(_categoria?.descrizione ?? 'Nuova Categoria'),
      ),
      resizeToAvoidBottomInset: false,
      body: _isLoading ?
        SizedBox(
        height:
        MediaQuery.of(context).size.height / 1.3,
    child: const Center(
    child: CircularProgressIndicator()),
    )
          : WillPopScope(onWillPop: null, child: stackWidget()),
      floatingActionButton: FloatingActionButton(
          elevation: 0.0,
          child: _updateMode ? UiIcons.save :  UiIcons.arrowRightAlt,
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
              categoriaEditCard(),
            ],
          )),
    );
  }





  _onSave() async{

    final form = _formKey.currentState!;

    bool valid=true;
    if (form.validate()) {
      form.save();


      if(!_updateMode && _categorieList!.any((item) => item.codice == int.parse(_categoria?.codice??'0'))){
        bool? ok = await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return new WillPopScope(
                onWillPop: null,
                child: new AlertDialog(
                  title:Text("Attenzione"),
                  content: Text("È già presente una categoria con questo tipologia, vuoi continuare?"),
                  actions: <Widget>[
                    TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                        ),
                        child: Text("ANNULLA"),
                        onPressed: () {
                          Navigator.pop(context, false);
                        }),
                    TextButton(
                        style: ButtonStyle(
                          padding: MaterialStateProperty.all<EdgeInsets>(
                              EdgeInsets.all(15)),
                        ),
                        child:  Text("PROCEDI"),
                        onPressed: () {
                          Navigator.pop(context, true);
                        }),
                  ],
                ));
          },
        );
        if(!ok!){
          valid=false;
          return;
        }
      }
      if(valid){
        _categoria!.descrizione = _catDescrizione;
        _categoria!.codice = _catCodice;
       await _save(context);
      }
    }
  }

  Future<void> _save(BuildContext context) async {
    setState(() {
      _isLoading=true;
    });
   WSResponse resp = await CategorieProdottiRestService.internal(context).upsertCategoriaProdotto(_categoria!);

   setState((){
      _isLoading=false;
   });

   if(resp.success!=null && resp.success!){
     debugPrint("figo, tutto bene");
   }else{
     debugPrint("e no ciccio!");
   }
   updateDialog(context,resp);

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


  Widget categoriaEditCard(){
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Card(
          color: Color(0xFFF1E6FF),
          elevation: 1.0,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    style: TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: "Nome della Categoria",
                      labelStyle: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    controller: _catDescrizioneController,
                    validator: _validateEmpty,
                    onSaved: (val) => _catDescrizione = val,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    style: TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: "Codice della Categoria",
                      labelStyle: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    controller: _catCodiceController,
                    validator: _validateEmpty,
                    onSaved: (val) => _catCodice = val,
                  ),
                ),
              ]),),

      ),
    );
  }


  String? _validateEmpty(String? value) {
    if (value!.isEmpty) {
      return "Campo obbligatorio";
    }
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message,style: TextStyle(color: Colors.red,fontSize: 16)));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }


}
