import 'dart:io';

import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/screens/categorie_prodotti/categorie_prodotti_screen.dart';
import 'package:bufalabuona/screens/drawer_item.dart';
import 'package:bufalabuona/screens/drawer_menu_divider.dart';
import 'package:bufalabuona/screens/drawer_menu_item.dart';
import 'package:bufalabuona/screens/listini/listini_screen.dart';
import 'package:bufalabuona/screens/login/profile_screen.dart';
import 'package:bufalabuona/screens/ordini/list_ordini_admin_screen.dart';
import 'package:bufalabuona/screens/ordini/storico_ordini_admin_screen.dart';
import 'package:bufalabuona/screens/ordini/storico_ordini_utente_screen.dart';
import 'package:bufalabuona/screens/prodotti/prodotti_screen.dart';
// import 'package:bufalabuona/screens/prodotti/prodotti_list.dart';
import 'package:bufalabuona/screens/punti_vendita/punti_vendita_screen.dart';
import 'package:bufalabuona/screens/report_confezionamento/report_confezionamento_screen.dart';
import 'package:bufalabuona/screens/report_produzione/report_produzione_screen.dart';
import 'package:bufalabuona/screens/utenti/gestione_utenti_screen.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:bufalabuona/utils/ui_colors.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';

import '../../main.dart';
import '../../model/report_confezionamento.dart';
import '../../utils/store_utils.dart';
import '../../utils/ui_icons.dart';
import '../categorie_punti_vendita/categorie_screen.dart';

class HomeAdmin extends StatefulWidget {
  final Map<String?, dynamic>? options;
  const HomeAdmin({Key? key, required this.options}) : super(key: key);

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  late final FirebaseMessaging _messaging;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? fcmToken;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String appVersion = '';
  Map? googleData;
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
  static const int MENU_ADMIN_ORDINI = 5;
  static const int MENU_ADMIN_ORDINI_IN_CONSEGNA = 51;
  static const int MENU_ADMIN_CAT_PRODOTTI = 6;
  static const int MENU_ADMIN_REPORT_PRODUZIONE = 7;
  static const int MENU_ADMIN_CATEGORIE=8;
  static const int MENU_ADMIN_CONFEZIONAMENTO=9;
  static const int MENU_PROFILO = 10;

  static const int MENU_LOGOUT = 99;

  Utente? _utente;
  Map<String?, dynamic>? _options;

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    _options = this.widget.options;
    initUtente();
    AppUtils.utente = _utente!;
    firebaseCloudMessagingListeners();
    init();
  }

  initUtente() async {

    if(_options!=null){
      _options = this.widget.options;
      if(_options!['utente']!=null){
        _utente = _options!['utente'];
        roles.add(_utente!.ruolo);
        if (roles.contains("admin")) {
          hasProfiloAdmin = true;
        } else {
          hasProfiloClient = true;
        }
      }
    }else{
      debugPrint("qua non ci dovrei manco passare");
      // _utente= await _loadUtente(user!.id);
    }
    await manageFirebaseToken();
    _options!['utente']=_utente;
  }

  Future init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = '${packageInfo.version}-${packageInfo.buildNumber}';

    debugPrint("##### INiT CheCK VeRSioN");
    /* TODO ABILITARE QUANDO SI VA SULLO STORE
      checkVersion();
    */

    drawerItems = await initMenuItems(context, roles);

    ///MAPPA DI APPOGGIO PER LA GESTIONE DEL MENÙ
    ///UTILIZZATA PER LA SELAZIONE DEGLI ELEMENTI DEL DRAWER
    Map<int, int?> menuItems = Map();

    drawerItems.forEachIndexed((index, element) {
      menuItems[index] = element.id;
    });

    if (hasProfiloAdmin) {
      _initialIndex =
          menuItems.keys.firstWhere((k) => menuItems[k] == MENU_ADMIN_ORDINI);

    }
    if (hasProfiloClient) {
      _initialIndex =
          menuItems.keys.firstWhere((k) => menuItems[k] == MENU_PROFILO);
    }

    _options;
    if (_options!= null && _options!['route']!=null) {
      if (_options!['route'] == 'ORDINI') {
        _initialIndex= menuItems.keys.firstWhere((k) => menuItems[k]==MENU_ADMIN_ORDINI, orElse:()=> 1);
      }
    }else{
      _options!['roles']=roles;
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
      case MENU_ADMIN_ORDINI:
        return StoricoOrdiniAdminScreen();
      case MENU_ADMIN_ORDINI_IN_CONSEGNA:
        return ListOrdiniAdminScreen();
      case MENU_PROFILO:
        return ProfileScreen(options: _options,);
      case MENU_ADMIN_CAT_PRODOTTI:
        return CategorieProdottiScreen();
      case MENU_ADMIN_CATEGORIE:
        return CategorieScreen();
      case MENU_ADMIN_REPORT_PRODUZIONE :
        return ReportProduzioneScreen();
      case MENU_ADMIN_CONFEZIONAMENTO :
        return ReportConfezionamentoScreen();
      default:
        return ProfileScreen(options: _options);
    }
  }

  Future<List<DrawerItem>> initMenuItems(
      BuildContext context, List<String?> roles) async {
    List<DrawerItem> drawerItems = [];

    if (hasProfiloAdmin) {
      var vetDrawerItems = [
        DrawerMenuDivider(null, "Amministrazione", Colors.blue),
        DrawerMenuItem(MENU_ADMIN_ORDINI, "Ordini In Arrivo",UiIcons.incoming),
        DrawerMenuItem(MENU_ADMIN_ORDINI_IN_CONSEGNA, "Ordini In Consegna", UiIcons.truckFast),
        DrawerMenuItem(MENU_ADMIN_REPORT_PRODUZIONE, "Report Produzione", UiIcons.chartPie),
        // DrawerMenuItem(MENU_ADMIN_CONFEZIONAMENTO, "Report Confezionamento", UiIcons.box),
        DrawerMenuDivider(null, "Gestione Prodotti", Colors.orange),
        DrawerMenuItem(MENU_ADMIN_PRODOTTI, "Elenco Prodotti",UiIcons.cheese),
        DrawerMenuItem(MENU_ADMIN_CAT_PRODOTTI, "Categorie Prodotti", UiIcons.tags),
        DrawerMenuItem(MENU_ADMIN_LISTINI, "Listini Prezzo", UiIcons.cashRegister),
        DrawerMenuDivider(null, "Gestione Utenti e Punti Vendita", Colors.pink),
        DrawerMenuItem(MENU_ADMIN_UTENTI, "Gestione Utenti", UiIcons.users),
        DrawerMenuItem(MENU_ADMIN_PUNTI_VENDITA, "Punti Vendita", UiIcons.store),
        DrawerMenuItem(MENU_ADMIN_CATEGORIE, "Categorie Punti Vendita", UiIcons.shoes),
      ];
      drawerItems.addAll(vetDrawerItems);
    }
    var dataItems = [
      DrawerMenuDivider(null, "Dati Personali", Colors.red),
      DrawerMenuItem(MENU_PROFILO, "Profilo",UiIcons.user,
          subtitle: "profilo personale"),
      DrawerMenuItem(
          MENU_LOGOUT, "Esci", UiIcons.exit)
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
      color: UiColors.PRIMARY,
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
                  backgroundColor: Colors.white,
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
            .join(),style: TextStyle(fontWeight: FontWeight.w900,color: UiColors.PRIMARY,fontSize: 22),);
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
              onPressed: () => _closeApp(),
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

  void registerNotification() async {
    // 1. Initialize the Firebase app
    await Firebase.initializeApp();

    // 2. Instantiate Firebase Messaging
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 3. On iOS, this helps to take the user permissions
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
      // TODO: handle the received notifications
    } else {
      debugPrint('User declined or has not accepted permission');
    }
  }
  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint("Handling a background message: ${message.messageId}");
  }

  void firebaseCloudMessagingListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      debugPrint("message recieved");
      debugPrint(event.notification!.title);
      debugPrint(event.notification!.body);
      if (event.notification != null) {
        debugPrint('Message also contained a notification: ${event.notification}');
      }
      showNotificationDialog(event.notification);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Message clicked!');
      debugPrint(message.notification!.title);
      debugPrint(message.notification!.body);
      showNotificationDialog(message.notification);
    });

    // _firebaseMessaging.requestPermission(
    //     sound: true, badge: true, alert: true, provisional: false);

    _firebaseMessaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false );
    _checkForFirebaseInitialMessage();
  }

  void _checkForFirebaseInitialMessage() async {
    await Firebase.initializeApp();
    RemoteMessage? initialMessage =
    await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      showNotificationDialog(initialMessage.notification);
    }
  }

  void showNotificationDialog(RemoteNotification? notification) async {
    String? title = notification?.title;
    String? body = notification?.body;
    await showDialog<String>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return  WillPopScope(
              onWillPop: null,
//              child: CustomDialog(buttonText: "OK",description: body,title: title,image: FarmacoIcons.presVetIcon),
              child:  AlertDialog(
                title: Text("ATTENZIONE"),
                content: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$title",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      Text("$body")
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                            EdgeInsets.all(15)),
                      ),
                      child: Text("OK"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              ));
        });
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  manageFirebaseToken() async {

    String? token = await _firebaseMessaging.getToken();
    debugPrint("FCM TOKEN = $token");
    //call store procedure in supabase "update_fcm_key"
    String? deviceId = await PlatformDeviceId.getDeviceId;
    Map<String,dynamic> mapInfo = await AppUtils.getDeviceInfo();

    Map<String,String?> parameters = {'key':token,'device':deviceId};
    String? puntovendita = '${_utente!.puntoVendita}';
    String? info = mapInfo.toString();

    //chiamo la funzione sul db che salva per il token nella tabella 'store_fcm_user_keys'
    final res= await supabase.rpc('store_fcm_user_keys',params:{ 'email': _utente!.email,'key': token, 'device': deviceId, 'puntovendita': null, 'info':'admin' });


    res;

    fcmToken = await AppUtils.retrieveFcmToken();
    if (token == fcmToken) {
      debugPrint("FCM TOKEN = $token");
    } else {
      AppUtils.storeFcmToken(token!);

      debugPrint("FCM TOKEN = $token");
    }

    setState(() {
      this.fcmToken = token;
    });
  }

  void _closeApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }

  void checkVersion() async {
    if (await AppUtils.isConnected()) {
      debugPrint("CHECK VERSION!");
      StoreUtils.checkVersion(context, showOldDeviceDialog: false);
    }
  }
}
