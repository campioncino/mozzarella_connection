import 'package:badges/badges.dart';
import 'package:bufalabuona/components/auth_required_state.dart';
import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/model/listino.dart';
import 'package:bufalabuona/model/listino_prodotti_ext.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/screens/carrello/carello_utente_screen.dart';
import 'package:bufalabuona/screens/listini_prodotti/listini_prodotti_screen.dart';
import 'package:bufalabuona/screens/listini_prodotti/listino_utente_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../utils/custom_colors.dart';
import 'carrello/carrelloTemporaneo.dart';
import 'prodotti/prodotti_list.dart';
import 'profile_screen.dart';

class Home extends StatefulWidget {
  final Map<String?, dynamic>? options;

  const Home({Key? key,required this.options}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends AuthRequiredState<Home> {

  String appVersion = '';
  Map? googleData;
  int _currentIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  late List<Widget> _children;
  List<String?> roles = [];
  User? user;
  bool isAdmin = false;
  bool isAutorizzato = false;

  Utente? _utente;
  PuntoVendita? _puntoVendita;
  Map<String?, dynamic>? _options;
  bool hasProfiloAdmin = false;
  bool hasProfiloClient = false;

  PersistentTabController _controller = PersistentTabController(initialIndex: 1);


  @override
  void onAuthenticated(Session session) async {
    final _user = session.user;
    if (_user != null) {
      setState(() {
        user = _user;
      });
    }
  }


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
      }
    }else{
      debugPrint("qua non ci dovrei manco passare");
     // _utente= await _loadUtente(user!.id);
    }
  }

  initPuntoVendita() async {
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

  }

  @override
  void initState() {
    super.initState();
    _options = this.widget.options;
    // initUtente();
    // initPuntoVendita();
    // init();
  }

  List<Widget> _buildScreens() {
    return [
      ProfileScreen(utente: _utente),
      ListinoUtenteScreen(puntoVendita: this.widget.options!['puntoVendita'],listCart: carrelloTemporaneo,),
      CarrelloUtenteScreen(puntoVendita: this.widget.options!['puntoVendita'],listCart: carrelloTemporaneo,),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(

        icon: Icon(FontAwesomeIcons.userGear),
        title: ("Profilo"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(FontAwesomeIcons.listCheck),
        title: ("Prodotti"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: Badge(
            badgeContent: carrelloTemporaneo.isNotEmpty ? SizedBox(
                width: 11, height: 11, //badge size
                child:Center(  //aligh badge content to center
                    child:Text(carrelloTemporaneo.length.toString(), style: TextStyle(
                        color: Colors.white,  //badge font color
                        fontSize: 10 //badge font size
                    )
                    )
                )
            ):Container(height: 0,),
            badgeColor: Colors.purple,
            position: BadgePosition.topEnd(),
            animationDuration: Duration(milliseconds: 300),
            animationType: BadgeAnimationType.slide,
            child: Icon(FontAwesomeIcons.cartShopping)),
        title: ("Carrello"),
        activeColorPrimary: CupertinoColors.activeBlue,
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _buildScreens(),
      items: _navBarsItems(),
      confineInSafeArea: true,
      backgroundColor: Colors.white, // Default is Colors.white.
      handleAndroidBackButtonPress: true, // Default is true.
      resizeToAvoidBottomInset: true, // This needs to be true if you want to move up the screen when keyboard appears. Default is true.
      stateManagement: true, // Default is true.
      hideNavigationBarWhenKeyboardShows: true, // Recommended to set 'resizeToAvoidBottomInset' as true while using this argument. Default is true.
      decoration: NavBarDecoration(
        borderRadius: BorderRadius.circular(10.0),
        colorBehindNavBar: Colors.white,
      ),
      popAllScreensOnTapOfSelectedTab: true,
      popActionScreens: PopActionScreensType.all,
      itemAnimationProperties: ItemAnimationProperties( // Navigation Bar's items animation properties.
        duration: Duration(milliseconds: 200),
        curve: Curves.ease,
      ),
      screenTransitionAnimation: ScreenTransitionAnimation( // Screen transition animation on change of selected tab.
        animateTabTransition: true,
        curve: Curves.ease,
        duration: Duration(milliseconds: 200),
      ),
      navBarStyle: NavBarStyle.style6, // Choose the nav bar style with this property.
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

}
