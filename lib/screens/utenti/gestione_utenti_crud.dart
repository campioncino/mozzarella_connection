import 'dart:convert';

//import 'package:barcode_scan/barcode_scan.dart';
// import 'package:barcode_scan_fix/barcode_scan.dart';

import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/model/categoria.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/ws_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/app_utils.dart';
import '../../utils/ensure_visibility_textformfield.dart';
import '../../utils/menu_choice.dart';

class PuntiVenditaCrud extends StatefulWidget {
  final PuntoVendita? puntoVendita;
  final List<Categoria>? listaCategorie;
  PuntiVenditaCrud({this.puntoVendita, this.listaCategorie});

  @override
  State<StatefulWidget> createState() => new _PuntiVenditaCrudState();
}

class _PuntiVenditaCrudState extends State<PuntiVenditaCrud> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  FocusNode _focusNodeNomeController = new FocusNode();
  FocusNode _focusNodeIndirizzoController = new FocusNode();
  FocusNode _focusNodePartitaIvaController = new FocusNode();
  FocusNode _focusNodeNumeroTelefonoController = new FocusNode();
  FocusNode _focusNodeDtFinValController = new FocusNode();
  FocusNode _focusNodeCatIdController = new FocusNode();
  FocusNode _focusNodeIdFatturazioneController = new FocusNode();
  FocusNode _focusNodeCategoriaController = new FocusNode();

  var now = new DateTime.now();

  ScrollController? _scroll;
  FocusNode _focus = new FocusNode();

  TextEditingController? _nomeController;
  TextEditingController? _indirizzoController;
  TextEditingController? _partitaIvaController;
  TextEditingController? _numeroTelefonoController;
  TextEditingController? _dtFinValController;
  TextEditingController? _catIdController;
  TextEditingController? _idFatturazioneController;

  PuntoVendita? _puntoVendita;

  List<Categoria>? _listaCategorie;

  String? _nome;
  String? _indirizzo;
  String? _partitaIva;
  String? _numeroTelefono;
  String? _dtFinVal;
  String? _catId;
  MenuChoice? _categoria;
  String? _idFatturazione;
  List<MenuChoice> _listMenuChoice = [];
  List<DropdownMenuItem<MenuChoice>> _categorieItems = [];
  bool _isAbilitato = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _listaCategorie = this.widget.listaCategorie;
    _scroll = new ScrollController();
    _focus.addListener(() {
      _scroll!.jumpTo(-1.0);
    });

    initCategorieList();

    _puntoVendita = this.widget.puntoVendita ?? new PuntoVendita();

    _nomeController =
        new TextEditingController(text: _puntoVendita?.denominazione ?? '');
    _indirizzoController =
        new TextEditingController(text: _puntoVendita?.indirizzo ?? '');
    _partitaIvaController =
        new TextEditingController(text: _puntoVendita?.partitaIva ?? '');
    _numeroTelefonoController =
        new TextEditingController(text: _puntoVendita?.telefono ?? '');
    _dtFinValController =
        new TextEditingController(text: _puntoVendita?.dtFinVal ?? '');
    _catIdController =
        new TextEditingController(text: _puntoVendita?.catId?.toString() ?? '');
    _idFatturazioneController =
        new TextEditingController(text: _puntoVendita?.idFatturazione ?? '');
    _listMenuChoice;
    if (_puntoVendita?.catId != null) {
      _categoria = _listMenuChoice.firstWhere((element) {
        return element.key == _puntoVendita?.catId.toString();
      });
    }
    if (_puntoVendita?.dtFinVal != null) {
      _isAbilitato = false;
    }
  }

  void initCategorieList() async {
    _listaCategorie!.forEach((element) {
      MenuChoice e = new MenuChoice(element.id.toString(), element.descrizione);
      _listMenuChoice.add(e);
      _categorieItems
          .add(DropdownMenuItem(value: e, child: new Text(e.value!)));
    });
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
            title: Text("Punti Vendita"),
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
            child: const Icon(Icons.check),
            backgroundColor: const Color(0xFFE57373),
            onPressed: _validateInputs,
          )),
    );
  }

  Widget explainText() {
    return Column(
      children: const <Widget>[
        Text("Inserisci o modifica Punto Vendita",
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
              focusNode: _focusNodeNomeController,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Denominazione",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _nomeController,
                focusNode: _focusNodeNomeController,
                validator: _validateNome,
                onSaved: (val) => _nome = val,
              )),
          new Padding(padding: new EdgeInsets.all(5.0)),
          EnsureVisibleWhenFocused(
              focusNode: _focusNodeIndirizzoController,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Indirizzo",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _indirizzoController,
                focusNode: _focusNodeIndirizzoController,
                validator: _validateIndirizzo,
                onSaved: (val) => _indirizzo = val,
              )),
          new Padding(padding: new EdgeInsets.all(5.0)),

          EnsureVisibleWhenFocused(
              focusNode: _focusNodeNumeroTelefonoController,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Telefono",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _numeroTelefonoController,
                focusNode: _focusNodeNumeroTelefonoController,
                validator: _validateNome,
                onSaved: (val) => _numeroTelefono = val,
              )),
          new Padding(padding: new EdgeInsets.all(5.0)),

          EnsureVisibleWhenFocused(
              focusNode: _focusNodePartitaIvaController,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Partita Iva",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _partitaIvaController,
                focusNode: _focusNodePartitaIvaController,
                validator: _validateNome,
                onSaved: (val) => _partitaIva = val,
              )),
          new Padding(padding: new EdgeInsets.all(5.0)),
          EnsureVisibleWhenFocused(
              focusNode: _focusNodeIdFatturazioneController,
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: "Id Fatturazione",
                  labelStyle: TextStyle(
                    fontSize: 18.0,
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _idFatturazioneController,
                focusNode: _focusNodeIdFatturazioneController,
                validator: _validateNome,
                onSaved: (val) => _idFatturazione = val,
              )),
          Padding(padding: EdgeInsets.all(5.0)),
          InputDecorator(
            decoration: const InputDecoration(
              border: InputBorder.none,
              labelText: "Categoria",
            ),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<MenuChoice>(
              hint: Text('Seleziona'),
              value: _categoria,
              items: _categorieItems, //loadDerogaItems(),
              onChanged: onChangeCategoria,
            )),
          ),
          Padding(padding: EdgeInsets.all(5.0)),
          // EnsureVisibleWhenFocused(
          //     focusNode: _focusNodeDtFinValController,
          //     child:  TextFormField(
          //       decoration: const InputDecoration(
          //         labelText: "Dt Fin Val",
          //         labelStyle: TextStyle(
          //           fontSize: 18.0,
          //         ),
          //       ),
          //       keyboardType: TextInputType.text,
          //       controller: _dtFinValController,
          //       focusNode: _focusNodeDtFinValController,
          //       validator: _validateNome,
          //       onSaved: (val) => _dtFinVal = val,
          //     )),
          // new Padding(padding: new EdgeInsets.all(5.0)),
          Row(
            children: [
              Expanded(child: Text("Abilitato")),
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

  void onChangeCategoria(MenuChoice? selected) {
    setState(() {
      _categoria = selected;
      _catIdController!.text = _categoria!.key!;
    });
  }

  void _validateInputs() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();

      _puntoVendita!.indirizzo = _indirizzo!.toUpperCase();
      _puntoVendita!.denominazione = _nome!.toUpperCase();
      _puntoVendita!.telefono = _numeroTelefono!.toUpperCase();
      _puntoVendita!.partitaIva = _partitaIva!.toUpperCase();

      _puntoVendita!.idFatturazione = _idFatturazione;
      if (_puntoVendita!.dtFinVal == null && _isAbilitato == false) {
        _puntoVendita!.dtFinVal = DateTime.now().toString();
      }
      if (_catIdController == null || _catIdController!.text == null) {
        return AppUtils.errorSnackBar(_scaffoldKey, "Selezionare la categoria");
      } else {
        _puntoVendita!.catId = int.parse(_catIdController!.text);
      }
      _onSavePuntoVendita(context, _puntoVendita!);
    }
  }

  Future _onSavePuntoVendita(
      BuildContext context, PuntoVendita puntoVendita) async {
    WSResponse? resp;
    bool update = false;
    setState(() {
      _isLoading = true;
    });
    if (puntoVendita.id == null) {
      resp = await PuntiVenditaRestService.internal(context)
          .insertPuntoVendita(puntoVendita);
    } else {
      update = await PuntiVenditaRestService.internal(context)
          .updatePuntoVendita(puntoVendita);
    }
    setState(() {
      _isLoading = false;
    });
    debugPrint(update.toString());
    updateDialog(context, resp);
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  Future<void> updateDialog(BuildContext context, WSResponse? resp) async {
    String message = "Operazione avvenuta con successo";
    if (resp != null && resp.errors != null) {
      message = AppUtils.decodeHttpStatus(resp.status);
    }
    String title = "Attenzione";
    if(resp!.success!){
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
    return;
  }
}
