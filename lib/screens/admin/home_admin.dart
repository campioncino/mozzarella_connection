import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/screens/drawer_item.dart';
import 'package:bufalabuona/screens/drawer_menu_divider.dart';
import 'package:bufalabuona/screens/drawer_menu_item.dart';
import 'package:bufalabuona/screens/listini/listini_screen.dart';
import 'package:bufalabuona/screens/prodotti/prodotti_screen.dart';
// import 'package:bufalabuona/screens/prodotti/prodotti_list.dart';
import 'package:bufalabuona/screens/profile_screen.dart';
import 'package:bufalabuona/screens/punti_vendita/punti_vendita_screen.dart';
import 'package:bufalabuona/screens/utenti/gestione_utenti_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({Key? key, required this.options}) : super(key: key);
  // final Utente utente;
  final Map<String?, dynamic>? options;
  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int? _selectedDrawerIndex;
  int? _selectedItem;
  var _selectedPage;
  String _titleMenu = "";
  String? _selectedRoutePath;

  int _initialIndex = 0;
  List<String?> roles = [];
  bool hasProfiloAdmin = false;
  bool hasProfiloClient = false;

  List<DrawerItem> drawerItems = [];

  static const int MENU_ADMIN_UTENTI = 1;
  static const int MENU_ADMIN_LISTINI = 2;
  static const int MENU_ADMIN_PRODOTTI = 3;
  static const int MENU_ADMIN_PUNTI_VENDITA = 4;
  static const int MENU_PROFILO = 10;
  static const int MENU_LOGOUT = 99;

  String appVersion = '';
  Utente? _utente;
  Map<String?, dynamic>? _options;

  @override
  void initState() {
    _options = this.widget.options;
    initUtente();
    init();
  }

  initUtente() async {
    _options = this.widget.options;
    _utente = _options!['utente'];
    roles.add(_utente!.ruolo);
    if (roles.contains("admin")) {
      hasProfiloAdmin = true;
    } else {
      hasProfiloClient = true;
    }
  }

  Future init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = '${packageInfo.version}-${packageInfo.buildNumber}';

    // _options = this.widget.options;
    // _utente = _options!['utente'];
    // roles.add(_utente!.ruolo);
    drawerItems = await initMenuItems(context, roles);

    ///MAPPA DI APPOGGIO PER LA GESTIONE DEL MENÙ
    ///UTILIZZATA PER LA SELAZIONE DEGLI ELEMENTI DEL DRAWER
    Map<int, int?> menuItems = Map();

    drawerItems.forEachIndexed((index, element) {
      menuItems[index] = element.id;
    });

    if (hasProfiloAdmin) {
      _initialIndex =
          menuItems.keys.firstWhere((k) => menuItems[k] == MENU_ADMIN_UTENTI);
      ;
    }
    if (hasProfiloClient) {
      _initialIndex =
          menuItems.keys.firstWhere((k) => menuItems[k] == MENU_PROFILO);
    }

    setState(() {
      if (_initialIndex != null) {
        _titleMenu = (drawerItems[_initialIndex] as DrawerMenuItem).title;
        _selectedItem = (drawerItems[_initialIndex] as DrawerMenuItem).id;
        _selectedDrawerIndex = _initialIndex;
        _selectedPage = _getDrawerItemWidget(_selectedItem);
      }

      /// Sistema usato per andare alle voci di menù altrimenti selezionabili tramite
      /// _onSelectItem
      /// Permette di avere come padre solo la route della home
      /// e quindi cancellare tutto lo storico delle schermate precedenti
      if (_selectedRoutePath != null && _options != null) {
        _options!.remove('route');
        Navigator.pushNamed(context, '${_selectedRoutePath!}',
            arguments: _options);
        _selectedRoutePath = null;
      }
    });
  }

  _getDrawerItemWidget(int? pos) {
    switch (pos) {
      case MENU_ADMIN_UTENTI:
        return GestioneUtentiScreen();
      case MENU_ADMIN_LISTINI:
        return ListiniScreen();
      case MENU_ADMIN_PRODOTTI:
        return ProdottiScreen();
      case MENU_ADMIN_PUNTI_VENDITA:
        return PuntiVenditaScreen();
      case MENU_PROFILO:
        return ProfileScreen();
      default:
        return ProfileScreen();
    }
  }

  Future<List<DrawerItem>> initMenuItems(
      BuildContext context, List<String?> roles) async {
    List<DrawerItem> drawerItems = [];

    if (hasProfiloAdmin) {
      var vetDrawerItems = [
        DrawerMenuDivider(null, "Amministrazione", Colors.blue),
        DrawerMenuItem(
            MENU_ADMIN_UTENTI, "Gestione Utenti", Icon(FontAwesomeIcons.users)),
        DrawerMenuItem(MENU_ADMIN_LISTINI, "Listini",
            Icon(FontAwesomeIcons.basketShopping)),
        DrawerMenuItem(
            MENU_ADMIN_PRODOTTI, "Prodotti", Icon(FontAwesomeIcons.cheese)),
        DrawerMenuItem(MENU_ADMIN_PUNTI_VENDITA, "Punti Vendita",
            Icon(FontAwesomeIcons.store)),
      ];
      drawerItems.addAll(vetDrawerItems);
    }
    var dataItems = [
      DrawerMenuDivider(null, "Dati Personali", Colors.red),
      DrawerMenuItem(MENU_PROFILO, "Profilo", Icon(FontAwesomeIcons.user),
          subtitle: "profilo personale"),
      DrawerMenuItem(
          MENU_LOGOUT, "Esci", Icon(FontAwesomeIcons.arrowRightFromBracket))
    ];

    drawerItems.insertAll(0, dataItems);

    return drawerItems;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () => _exitApp(context),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            // here we display the title corresponding to the fragment
            // you can instead choose to have a static title
            title: Text(
              '$_titleMenu',
              maxLines: 2,
            ),
          ),
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                accountHeader(),
                drawerMenuItems(context, drawerItems),
              ],
            ),
          ),
          body: _selectedPage,
        ));
  }

  Widget accountHeader() {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      color: Colors.green,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                CircleAvatar(
                  child: circleAvatarText(),
                  radius: 25.0,
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _utente != null ? _utente!.username! : '',
                        textScaleFactor: 1.2,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _utente != null ? _utente!.email! : '',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Text(
              'Versione $appVersion',
              style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                  fontStyle: FontStyle.italic),
            ),
          )
        ],
      ),
    );
  }

  Widget circleAvatarText() {
    if (_utente != null && _utente!.name != null) {
      try {
        return Text(_utente!.name!
            .split(new RegExp(' +'))
            .map((f) => f.substring(0, 1).toUpperCase())
            .toList()
            .join());
      } catch (e) {
        return Text('');
      }
    }
    return Text('');
  }

  Future<bool> _exitApp(BuildContext context) async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        content: Text("USCIRE DALL'APP"),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("NO")),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text("SI")),
        ],
      ),
    );
    return ok!;
  }

  Widget drawerItem(BuildContext context, DrawerItem item, int index) {
    if (item is DrawerMenuItem) {
      return ListTile(
        dense: true,
        title: Text(item.title, style: TextStyle(fontSize: 14.0)),
        subtitle: item.subtitle != null
            ? new Text(item.subtitle!,
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic))
            : null,
        leading: item.icon,
        selected: index == _selectedDrawerIndex,
        onTap: () => _onSelectItem(index, item),
      );
    } else if (item is DrawerMenuDivider) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(item.title,
                      style: new TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: item.color)),
                  item.subtitle != null ? Text(item.subtitle!) : Container(),
                ],
              ),
            ),
          ]);
    }
    return Container();
  }

  Widget drawerMenuItems(BuildContext context, List<DrawerItem> drawerItems) {
    var drawerOptions = <Widget>[];
    for (var i = 0; i < drawerItems.length; i++) {
      drawerOptions.add(drawerItem(context, drawerItems[i], i));
    }
    return new Column(
      children: drawerOptions,
    );
  }

  void _onSelectItem(int index, DrawerMenuItem d) {
    // close the drawer
    Navigator.of(context).pop();
    switch (d.id) {
      case MENU_LOGOUT:
        _exitApp(context);
        break;

      default:
        setState(() {
          _selectedDrawerIndex = index;
          _selectedItem = d.id;
          _titleMenu = d.title;
          _selectedPage = _getDrawerItemWidget(_selectedItem);
        });
        break;
    }
  }
}
