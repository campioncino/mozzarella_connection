import 'package:bufalabuona/data/categorie_rest_service.dart';
import 'package:bufalabuona/data/listini_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:bufalabuona/utils/menu_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class ListiniCrud extends StatefulWidget {
  final Listino? listino;
  final bool? updateMode;
  final List<Listino>? listini ;

  const ListiniCrud({this.listino, @required this.updateMode,this.listini});

  @override
  State<ListiniCrud> createState() => _ListiniCrudState();
}

class _ListiniCrudState extends State<ListiniCrud> {
  final dateFormatter = new DateFormat('dd-MM-yyyy');

  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
  GlobalKey<ScaffoldMessengerState>();
  final _formKey = GlobalKey<FormState>();

  Listino? _listino;
  bool _isLoading = false;
  bool _updateMode = false;
  bool _isAbilitato = false;

  List<Categoria>? _listaCategorie;

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
  List<Listino>? _listini;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    init();
  }


  void init() async{
    setState((){
      _listino = this.widget.listino;
      _updateMode = this.widget.updateMode!;
      _listini = this.widget.listini;
    });

    await _loadCategorie();

    await _initCategorieList();
    await _initCategoriaCrud();

    setState(() {
      _isLoading=false;
      if(!_updateMode){
        _listino=new Listino();
      }else{
        _isAbilitato = _listino!.active!;

      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(_listino?.descrizione ?? 'Nuovo Listino'),
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
          child: _updateMode ?const Icon(Icons.save) : const Icon(Icons.arrow_right_alt),
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

              listinoEditCard(),
            ],
          )),
    );
  }






  _initCategoriaCrud() async {
    setState((){
      _catIdController = new TextEditingController();
      _listDescrizioneController = new TextEditingController(text: _listino?.descrizione ?? '');
      _dtFinValController = new TextEditingController(text: _listino?.dtFinVal ?? '');
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

    final form = _formKey.currentState!;

    bool valid=true;
    if (form.validate()) {
      form.save();

      if(_dtIniValController!.text.isEmpty){
        valid=false;
        showMessage("Selezionare la data di inizio validità");
        return;
      }


      if(_categoria==null){
        valid=false;
        showMessage("Selezionare una tipologia di punto vendita");
        return;
      }

      if(!_updateMode && _listini!.any((item) => item.catId == int.parse(_categoria!.key!))){
        bool? ok = await showDialog<bool>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return new WillPopScope(
                onWillPop: null,
                child: new AlertDialog(
                  title:Text("Attenzione"),
                  content: Text("È già presente un listino per questa tipologia, vuoi continuare?"),
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
        _listino!.catId = int.parse(_categoria!.key.toString());
        _listino!.active = _isAbilitato;
        _listino!.descrizione = _listDescrizioneController!.text;
        _listino!.dtIniVal= _dtIniValController!.text;
        if(_dtIniValController!.text!=null && _dtFinValController!.text.isNotEmpty){
          _listino!.dtFinVal = _dtFinValController!.text;
        }
       await _save(context);
      }
    }
  }

  Future<void> _save(BuildContext context) async {
    setState(() {
      _isLoading=true;
    });
   WSResponse resp = await ListiniRestService.internal(context).upsertListino(_listino!);

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


  Widget listinoEditCard(){
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
                      labelText: "Nome del Listino",
                      labelStyle: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    controller: _listDescrizioneController,
                    validator: _validateEmpty,
                    onSaved: (val) => _listDescrizione = val,
                  ),
                ),

                 GestureDetector(
                   onTap: () {
                     _chooseFreeDate(context, _dtIniValController!, true);
                   },
                   child: Container(
                     padding: EdgeInsets.all(10.0),
                     decoration: BoxDecoration(),
                     child: TextFormField(
                       enabled: false,
                       decoration: new InputDecoration(
                         labelStyle: TextStyle(color : Colors.green[900],fontSize: 18),
                         hintText: "Applicabile dal",
                         labelText: "Applicabile dal",
                         enabled: true,
                       ),
                       controller: _dtIniValController,
                     ),
                   ),
                 ),
                GestureDetector(
                  onTap: () {
                    _chooseFreeDate(context, _dtFinValController!, true);
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(),
                    child: TextFormField(
                      enabled: false,
                      decoration: new InputDecoration(
                        labelStyle: TextStyle(color : Colors.green[900],fontSize: 18),
                        hintText: "Applicabile fino al",
                        labelText: "Applicabile fino al",
                        enabled: true,
                      ),
                      controller: _dtFinValController,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      labelText: "Categoria",
                      labelStyle: TextStyle(color:Colors.green.shade900,fontSize: 18),
                    ),
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<MenuChoice>(
                          hint: Text('Seleziona'),
                          value: _categoria,
                          items: _categorieItems, //loadDerogaItems(),
                          onChanged: onChangeCategoria,
                        )),
                  ),
                ),
                abilitaSwitch(context),
              ]),),

      ),
    );
  }

  Widget abilitaSwitch(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
       Expanded(child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("Attivo",style: TextStyle(color:Colors.green.shade900,fontSize: 18),),
      )),
      Switch(
        activeColor: Colors.green,
        inactiveThumbColor: Colors.redAccent,
        value: _isAbilitato,
        onChanged: (bool value) {

            setState(() {
              _isAbilitato = value;
            });
        },
      ),]);}

  String? _validateEmpty(String? value) {
    if (value!.isEmpty) {
      return "Campo obbligatorio";
    }
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message,style: TextStyle(color: Colors.red,fontSize: 16)));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  Future _chooseFreeDate(BuildContext context,
      TextEditingController initialDateString, bool isDatePresent) async {
    TextEditingController textToSet = new TextEditingController();

    DateTime lastDate = new DateTime(2100);


    DateTime finalDate = new DateTime(1970);
    DateTime initialDate = new DateTime.now();
    if (isDatePresent) {
      textToSet = initialDateString;
    }
    if (initialDateString.text.isNotEmpty && !isDatePresent) {
      AppUtils.errorSnackBar(_scaffoldKey, 'Data Inizio Necessaria');
      return;
    }

    // if(initialDate.isAfter(lastDate)){
    //   lastDate=new DateTime(2100);
    // }

    var result = await showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: finalDate,
        lastDate: lastDate);
    if (result == null) return;
    setState(() {
      textToSet.text = dateFormatter.format(result);
    });
  }
}
