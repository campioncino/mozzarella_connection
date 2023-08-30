import 'dart:convert';

//import 'package:barcode_scan/barcode_scan.dart';
// import 'package:barcode_scan_fix/barcode_scan.dart';

import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/data/utenti_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:bufalabuona/screens/punti_vendita/lov_punti_vendita_fragment.dart';
import 'package:bufalabuona/utils/lov_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_utils.dart';
import '../../utils/ensure_visibility_textformfield.dart';
import '../../utils/menu_choice.dart';
import '../../utils/ui_icons.dart';

class GestioneUtentiCrud extends StatefulWidget {
  final Utente? utente;
  GestioneUtentiCrud({this.utente});

  @override
  State<StatefulWidget> createState() => new _GestioneUtentiCrudState();
}

class _GestioneUtentiCrudState extends State<GestioneUtentiCrud> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  FocusNode _focusNodeNomeController = new FocusNode();
  FocusNode focusNodeUsernameController = new FocusNode();
  FocusNode focusNodeEmailController = new FocusNode();
  FocusNode _focusNodePhoneNumberController = new FocusNode();
  FocusNode _focusNodeDtFinValController = new FocusNode();
  FocusNode _focusNodeCatIdController = new FocusNode();
  FocusNode _focusNodeIdFatturazioneController = new FocusNode();
  FocusNode _focusNodeCategoriaController = new FocusNode();

  var now = new DateTime.now();

  ScrollController? _scroll;
  FocusNode _focus = new FocusNode();

  TextEditingController? _nomeController;
  TextEditingController? _usernameController;
  TextEditingController? _emailController;
  TextEditingController? _phoneNumberController;
  TextEditingController? _dtFinValController;
  TextEditingController? _profileIdController;
  TextEditingController? _ruoloController;

  Utente? _utente;
  List<PuntoVendita>? _listaPuntoVendita;
  PuntoVendita? _puntoVenditaSelected;

  String? _nome;
  String? _username;
  String? _email;
  String? _phoneNumber;
  String? _dtFinVal;
  String? _profileId;
  MenuChoice? _categoria;
  String? _ruolo;
  List<MenuChoice> _listMenuChoice = [];
  List<DropdownMenuItem<MenuChoice>> _categorieItems = [];
  bool _isAbilitato = true;
  bool _isLoading = true;
  bool _editPersonalInfo = false;

  @override
  void initState() {
    super.initState();

    _scroll = new ScrollController();
    _focus.addListener(() {
      _scroll!.jumpTo(-1.0);
    });

    initPuntiVenditaList();

    _utente = this.widget.utente ?? new Utente();

    if(_utente!.puntoVendita!=null) {
      _puntoVenditaInit(_utente!.puntoVendita!);
    }
    _nomeController =
        new TextEditingController(text: _utente?.name ?? '');
    _usernameController =
        new TextEditingController(text: _utente?.username ?? '');
    _emailController =
        new TextEditingController(text: _utente?.email ?? '');
    _phoneNumberController =
        new TextEditingController(text: _utente?.phoneNumber ?? '');
    _dtFinValController =
        new TextEditingController(text: _utente?.dtFineValidita ?? '');
    _profileIdController =
        new TextEditingController(text: _utente?.profileId?.toString() ?? '');
    _ruoloController =
        new TextEditingController(text: _utente?.ruolo ?? '');

    if(_utente!=null && _utente!.confermato!=null) {
      _isAbilitato = _utente!.confermato!;
    }
    _listMenuChoice;
    // if (_utente?.profileId != null) {
    //   _categoria = _listMenuChoice.firstWhere((element) {
    //     return element.key == _utente?.profileId.toString();
    //   });
    // }
    if (_utente?.dtFineValidita != null) {
      _isAbilitato = false;
    }
  }

  void initPuntiVenditaList() async {
    if(_utente!=null && _utente!.puntoVendita!=null){
      _puntoVenditaSelected = await PuntiVenditaRestService.internal(context).getPuntoVendita(_utente!.puntoVendita!);
    }
    // _listaPuntoVendita!.forEach((element) {
    //   MenuChoice e = new MenuChoice(element.id.toString(), element.descrizione);
    //   _listMenuChoice.add(e);
    //   _categorieItems
    //       .add(DropdownMenuItem(value: e, child: new Text(e.value!)));
    // });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      key: _scaffoldKey,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Utenti"),
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
            child:  UiIcons.save,
            onPressed: _validateInputs,
          )),
    );
  }

  Widget explainText() {
    return Column(
      children: const <Widget>[
        Text("Abilita o disabilita utenti",
            style: TextStyle(fontStyle: FontStyle.italic)),
      ],
    );
  }

  Widget crudText() {
    return Row(children: [
      Expanded(
          child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
             _editPersonalInfo ? utenteEditCard() : utenteCard(),
              SizedBox(height: 10,),
              if(_utente!.ruolo!='admin') lovPuntoVendita(context),
              SizedBox(height: 15,),
              abilitaSwitch(context),
        ]),
      ))
    ]);
  }

  String? _validateEmpty(String? value) {
    if (value!.isEmpty) {
      return "Campo obbligatorio";
    }
  }


  void onChangeCategoria(MenuChoice? selected) {
    setState(() {
      _categoria = selected;
      _profileIdController!.text = _categoria!.key!;
    });
  }

  void _validateInputs() async {
    final form = _formKey.currentState!;
    bool? saveWithoutPV;
    if (form.validate()) {
      form.save();
      if(_puntoVenditaSelected!=null){
      _utente!.puntoVendita = _puntoVenditaSelected!.id!;
      }

      if(_puntoVenditaSelected == null && _utente!.ruolo!='admin'){
        debugPrint("attenzione,nessun punto ventita selezionato");
        saveWithoutPV =await askContinua(context);
      }
      if(_editPersonalInfo){
        _utente!.username = this._username;
        _utente!.name = this._nome;
        _utente!.phoneNumber = this._phoneNumber;
        _utente!.email = this._email;

      }
      if(saveWithoutPV!=null && !saveWithoutPV) {
        _utente!.puntoVendita = _puntoVenditaSelected!.id!;
      }

      _utente!.confermato = this._isAbilitato;

     _onSaveUtente(context, _utente!);
    }
  }

  Future _onSaveUtente(BuildContext context, Utente utente) async {
    WSResponse? resp;
    bool update = false;
    setState(() {
      _isLoading = true;
    });

    if (utente.profileId == null) {
      ///Todo vedere se abilitare o meno l'inserimento dell'utente da parte dell'admin
      // resp = await PuntiVenditaRestService.internal(context)
      //     .insertPuntoVendita(utente);
    } else {
      update = await UtentiRestService.internal(context).upsertUtente(utente);
    }
    setState(() {
      _isLoading = false;
    });
    updateDialog(context, update);
  }


  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  Future<void> updateDialog(BuildContext context, bool? resp) async {
    String message = "Operazione avvenuta con successo";
    if (resp != null ) {
      message = AppUtils.decodeHttpStatus(200);
    }
    String title = "Attenzione";
    if(resp!){
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
    // return;
    Navigator.pop(context,true);
  }

  Future<bool?> askContinua(BuildContext context) async {
    String title = "Attenzione";
    String message ="Non c'è alcun punto vendita associato all'utente.\nSenza punto vendita associato, non sarà possibile abilitare l'utente.\nContinuare e salvare i dati?";
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title,style: TextStyle(fontWeight: FontWeight.bold),),
        content: Text(message),
          actions: <Widget>[
            TextButton(
            child: Text("ANNULLA"),
            onPressed: () {
            Navigator.pop(context,false);
            }),
            TextButton(
            child: Text("OK"),
            onPressed: () {
            Navigator.pop(context,true);
            })]
              ),
    );
  }

  Widget abilitaSwitch(BuildContext context) {
    return Card(
        margin: EdgeInsets.all(0.0),
        elevation:  2.0,
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Expanded(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text("Abilitato"),
        )),
    Switch(
      activeColor: Colors.green,
    inactiveThumbColor: Colors.redAccent,
    value: _isAbilitato,
    onChanged: (bool value) {
    if(_utente!.ruolo=='admin' || _puntoVenditaSelected!=null){
      setState(() {
      _isAbilitato = value;
      });}
    },
    ),]));}

  Widget lovPuntoVendita(BuildContext context) {
    var builder =  LovPuntiVenditaFragment(
      appbarTitle: "punti vendita",
      onSearch: _searchPuntoVendita,
      showInsert: true,
    );

    return  LovWidget<PuntoVendita?>(
        object: this._puntoVenditaSelected,
        headerFunction: (p) {
          return const Text(
            "PUNTO VENDITA",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              // color: Colors.black54,
            ),
          );
        },
        titleFunction: (p) {
          if (p == null) {
            return const Text("Seleziona Punto vendita",
                style:  TextStyle(
                  fontSize: 14.0,
                  fontStyle: FontStyle.normal,
                ));
          }
          return Text('${p.denominazione ?? ''}',
              style:  TextStyle(
                fontSize: 16.0,
                fontStyle: FontStyle.normal,
              ));
        },
        subtitleFunction: (p) {
          var sub1 = () {
            if (p != null) {
              return Text('${p.indirizzo?.toLowerCase()}',
                  style:  TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ));
            }
            return Container();
          };
          var sub2 = () {
            if (this._puntoVenditaSelected == null) {
              return Container();
            }
            if (!_puntoVenditaEnabled()) {
              return Text("Devi Definire prima il ruolo",
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600]));
            }
            return Container();
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[sub1(), sub2()],
          );
        },
        builder: builder,
        onSelected: (selected) => _puntoVenditaSelect(selected),
        onRemoved: () => _puntoVenditaRemoved(),
        enabled: true
    );
  }

  _searchPuntoVendita() async {
    WSResponse resp = await PuntiVenditaRestService.internal(context).getAll();
    return PuntiVenditaRestService.internal(context).parseList(resp.data!.toList());
  }

  _puntoVenditaSelect( PuntoVendita selected) {
    setState(() {
      _puntoVenditaSelected = selected;
    });
  }

  _puntoVenditaInit( int id) async {
    PuntoVendita? resp = await PuntiVenditaRestService.internal(context).getPuntoVendita(id);
    resp;
    setState(() {
      _puntoVenditaSelected =  resp ?? new PuntoVendita();
    });
  }

  _puntoVenditaRemoved() {
    setState(() {
      _puntoVenditaSelected = null;
      _isAbilitato = false;
    });
  }

  bool _puntoVenditaEnabled() {
    if (_ruolo == null || _ruolo =='admin') {
      return true;
    }else{

    }
    return true;
  }

  Widget utenteCard(){
    return Card(margin: EdgeInsets.all(0.0),
       color: Color(0xFFF1E6FF),
      elevation:  3.0,
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(UiIcons.circleUserIco,size: 44,),
        ),
      Expanded(child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0,vertical: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_utente!.username?? ''),
            Text(_utente!.name?? '',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22),),
            Text(_utente!.email?? ''),
            Text(_utente!.phoneNumber??''),
           if(_utente!.ruolo=='admin') Container(width: 80,color:Colors.red,child:Center(child: Text('ADMIN',style: TextStyle(fontWeight:FontWeight.w500,color: Colors.white ))))
          ],
        ),
      )),
        IconButton(onPressed: _editPersonalInformation, icon: UiIcons.pencil)
      ]
      ));
  }

  void _editPersonalInformation() {
    setState(() {
      _editPersonalInfo=true;
    });
  }

  Widget utenteEditCard(){
    return Card(
      elevation: 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: EnsureVisibleWhenFocused(
                focusNode: focusNodeEmailController,
                child: TextFormField(
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    labelStyle: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  controller: _emailController,
                  focusNode: focusNodeEmailController,
                  validator: _validateEmpty,
                  onSaved: (val) => _email = val,
                )),
          ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: EnsureVisibleWhenFocused(
            focusNode: _focusNodeNomeController,
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Nome",
                labelStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              keyboardType: TextInputType.text,
              controller: _nomeController,
              focusNode: _focusNodeNomeController,
              validator: _validateEmpty,
              onSaved: (val) => _nome = val,
            )),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: EnsureVisibleWhenFocused(
            focusNode: focusNodeUsernameController,
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Username",
                labelStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              keyboardType: TextInputType.text,
              controller: _usernameController,
              focusNode: focusNodeUsernameController,
              // validator: (){},
              onSaved: (val) => _username = val,
            )),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: EnsureVisibleWhenFocused(
            focusNode: _focusNodePhoneNumberController,
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: "Telefono",
                labelStyle: TextStyle(
                  fontSize: 18.0,
                ),
              ),
              keyboardType: TextInputType.text,
              controller: _phoneNumberController,
              focusNode: _focusNodePhoneNumberController,
              validator: _validateEmpty,
              onSaved: (val) => _phoneNumber = val,
            )),
      ),

      // Padding(
      //   padding: const EdgeInsets.all(8.0),
      //   child: EnsureVisibleWhenFocused(
      //       focusNode: _focusNodeIdFatturazioneController,
      //       child: TextFormField(
      //         decoration: const InputDecoration(
      //           labelText: "Ruolo",
      //           labelStyle: TextStyle(
      //             fontSize: 18.0,
      //           ),
      //         ),
      //         keyboardType: TextInputType.text,
      //         controller: _ruoloController,
      //         focusNode: _focusNodeIdFatturazioneController,
      //         validator: _validateEmpty,
      //         onSaved: (val) => _ruolo = val,
      //       )),
      // ),
    ]),);
  }

}
