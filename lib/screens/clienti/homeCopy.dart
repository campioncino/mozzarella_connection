import 'dart:io';

import 'package:bufalabuona/main.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/screens/drawer_item.dart';
import 'package:bufalabuona/screens/drawer_menu_divider.dart';
import 'package:bufalabuona/screens/drawer_menu_item.dart';
import 'package:bufalabuona/screens/listini_prodotti/listino_utente_screen.dart';
import 'package:bufalabuona/screens/login/profile_screen.dart';
import 'package:bufalabuona/screens/ordini/storico_ordini_utente_screen.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:collection/collection.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class Home extends StatefulWidget {
  final Map<String?, dynamic>? options;
  final Map<ListinoProdottiExt,int>? listCart;
  const Home({Key? key,required this.options, this.listCart}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late final FirebaseMessaging _messaging;

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? fcmToken;

  String appVersion = '';
  Map? googleData;
  int _currentIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  List<String?> roles = [];
  User? user;
  bool isAdmin = false;
  bool isAutorizzato = false;

  Utente? _utente;
  PuntoVendita? _puntoVendita;
  Map<String?, dynamic>? _options;
  bool hasProfiloAdmin = false;
  bool hasProfiloClient = false;

  int? _selectedDrawerIndex;
  int? _selectedItem;
  var _selectedPage;
  String _titleMenu = "";
  String? _selectedRoutePath;

  int _initialIndex = 0;

  List<DrawerItem> drawerItems = [];

  late Map<ListinoProdottiExt,int> _listCart;


  static const int MENU_USER_PRODOTTI = 1;
  static const int MENU_USER_CART = 2;
  static const int MENU_USER_ORDER = 3;
  static const int MENU_USER_STORICO_ORDINI = 3;
  static const int MENU_USER_PROFILO = 10;
  static const int MENU_LOGOUT = 99;

  // @override
  // void onAuthenticated(Session session) async {
  //   final _user = session.user;
  //   if (_user != null) {
  //     setState(() {
  //       user = _user;
  //     });
  //   }
  // }


  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
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
      if(_options!['puntoVendita']!=null){
        _puntoVendita = _options!['puntoVendita'];
        AppUtils.puntoVendita = _puntoVendita!;
      }
    }else{
      debugPrint("qua non ci dovrei manco passare");
      // _utente= await _loadUtente(user!.id);
    }
    await manageFirebaseToken();
  }


  void firebaseCloudMessagingListeners() {
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      debugPrint("message recieved");
      debugPrint(event.notification!.title);
      debugPrint(event.notification!.body);
      if (event.notification != null) {
        print('Message also contained a notification: ${event.notification}');
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


  init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appVersion = '${packageInfo.version}-${packageInfo.buildNumber}';
    // WidgetsBinding.instance.addPostFrameCallback((_){
    //   _loadUtente(user!.id);
    // });
    if(_utente!=null){
      if(_utente!.confermato!){
        setState(() {
          isAutorizzato = true;
        });
      }
      if(_utente!.ruolo=='admin'){
        setState(() {
          isAdmin = true;
        });
      }
    }

    drawerItems = await initMenuItems(context, roles);

    ///MAPPA DI APPOGGIO PER LA GESTIONE DEL MENÙ
    ///UTILIZZATA PER LA SELAZIONE DEGLI ELEMENTI DEL DRAWER
    Map<int, int?> menuItems = Map();

    drawerItems.forEachIndexed((index, element) {
      menuItems[index] = element.id;
    });

    if (hasProfiloClient) {
      _initialIndex =
          menuItems.keys.firstWhere((k) => menuItems[k] == MENU_USER_PRODOTTI);
    }

    _options;
    if (_options!= null && _options!['route']!=null) {
      if (_options!['route'] == 'ORDINI') {
        _initialIndex= menuItems.keys.firstWhere((k) => menuItems[k]==MENU_USER_STORICO_ORDINI, orElse:()=> 6);
      }
      if (_options!['route'] == 'PRODOTTI') {
        _initialIndex= menuItems.keys.firstWhere((k) => menuItems[k]==MENU_USER_PRODOTTI, orElse:()=> 6);
      }
    }else{
      _options={'roles':roles};
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

  @override
  void initState() {
    super.initState();
    Firebase.initializeApp();
    _options = this.widget.options;
    if(this.widget.listCart!=null) {
      _listCart = this.widget.listCart!;
    }else{
      _listCart = new Map();
    }
    // stopAuthObserver();
    initUtente();
    AppUtils.utente = _utente!;
    firebaseCloudMessagingListeners();
    //TODO GESTIRE I TOKEN E SALVARLI SU DB
    // manageFirebaseToken();
    init();
  }

  _getDrawerItemWidget(int? pos) {
    switch (pos) {
      case MENU_USER_PRODOTTI:
        return ListinoUtenteScreen(puntoVendita: _puntoVendita,listCart: _listCart,);

    // case MENU_USER_CART:
    //     return CarrelloUtenteScreen(puntoVendita: this.widget.options!['puntoVendita'],listCart: _listCart);

     case MENU_USER_ORDER:
        return  StoricoOrdiniScreen(puntoVendita: this.widget.options!['puntoVendita']);
      case MENU_USER_STORICO_ORDINI:
        return  StoricoOrdiniScreen(puntoVendita: this.widget.options!['puntoVendita']);
      case MENU_USER_PROFILO:
        return ProfileScreen(options: this.widget.options,);
      default:
        return ProfileScreen(options: this.widget.options);
    }
  }


  Future<List<DrawerItem>> initMenuItems(
      BuildContext context, List<String?> roles) async {
    List<DrawerItem> drawerItems = [];

    if (hasProfiloClient) {
      var vetDrawerItems = [
        DrawerMenuDivider(null, "Bufala Buona", Colors.blue),
        DrawerMenuItem(
            MENU_USER_PRODOTTI, "Prodotti", Icon(FontAwesomeIcons.listCheck)),
        // DrawerMenuItem(MENU_USER_CART, "Carrello",
        //     Icon(FontAwesomeIcons.cartShopping)),
        DrawerMenuItem(
            MENU_USER_ORDER, "Ordini", Icon(FontAwesomeIcons.cheese)),
        DrawerMenuItem(MENU_USER_STORICO_ORDINI, "Storico Ordini",
            Icon(FontAwesomeIcons.store)),
      ];
      drawerItems.addAll(vetDrawerItems);
    }
    var dataItems = [
      DrawerMenuDivider(null, "Dati Personali", Colors.red),
      DrawerMenuItem(MENU_USER_PROFILO, "Profilo", Icon(FontAwesomeIcons.user),
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
        //  bottomNavigationBar: BottomNavigationBar(
        //    onTap: onTabTapped,
        //    currentIndex: _currentIndex,
        //    selectedItemColor: Colors.amber[800],
        // items: const <BottomNavigationBarItem>[
        //   BottomNavigationBarItem(
        //     icon: Icon(FontAwesomeIcons.shop,color: Colors.grey,),
        //     // backgroundColor: Colors.lightBlueAccent,
        //     label: 'Prodotti',
        //   ),
        //   BottomNavigationBarItem(
        //         icon: Icon(FontAwesomeIcons.solidHeart,color: Colors.grey),
        //         label: 'Pref',
        // ),
        //
        //   BottomNavigationBarItem(
        //         icon: Icon(FontAwesomeIcons.boxArchive,color: Colors.grey),
        //         label: 'Ordini',
        //   ),
        //   BottomNavigationBarItem(
        //         icon: Icon(FontAwesomeIcons.person,color: Colors.grey),
        //         label: 'Profilo',
        //         activeIcon: Icon(FontAwesomeIcons.person,color: Colors.orangeAccent),
        //   ),
        //   ],
        //   ),
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



  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;

        // _selectedDrawerIndex = index;
        // // _selectedItem = d.id;
        // // _titleMenu = d.title;
        // _selectedPage = _getDrawerItemWidget(_selectedItem);
    });

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

  goToCart(){
    setState(() {
      _selectedDrawerIndex = 2;
      _selectedItem = MENU_USER_CART;
      _titleMenu = "Carrello";
      _selectedPage = _getDrawerItemWidget(_selectedItem);
    });
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
    final res= await supabase.rpc('store_fcm_user_keys',params:{ 'email': _utente!.email,'key': token, 'device': deviceId, 'puntovendita': _utente!.puntoVendita, 'info':_utente!.username  });


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
      print('User granted permission');
      // TODO: handle the received notifications
    } else {
      print('User declined or has not accepted permission');
    }
  }
  Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }
}
