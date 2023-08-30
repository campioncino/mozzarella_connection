import 'dart:io';

import 'package:bufalabuona/screens/home_admin/home_admin.dart';
import 'package:bufalabuona/screens/bufala_router.dart';
import 'package:bufalabuona/screens/home_clienti/home.dart';
import 'package:bufalabuona/screens/courtesy/confirmed_order_screen.dart';
import 'package:bufalabuona/screens/login/change_password.dart';
import 'package:bufalabuona/screens/login/forgot_password.dart';
import 'package:bufalabuona/screens/login/profile_screen.dart';
import 'package:bufalabuona/screens/login/profile_unauthorized.dart';
import 'package:bufalabuona/screens/login/signin_screen.dart';
import 'package:bufalabuona/screens/login/signup_screen.dart';
import 'package:bufalabuona/screens/prodotti/prodotti_list.dart';
import 'package:bufalabuona/screens/web_home_screen.dart';
import 'package:bufalabuona/utils/ui_colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_seed_scheme/flex_seed_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'model/utente.dart';



final ColorScheme schemeLight = SeedColorScheme.fromSeeds(
  brightness: Brightness.light,
  // Primary key color is required, like seed color ColorScheme.fromSeed.
  primaryKey: UiColors.PRIMARY,
  // You can add optional own seeds for secondary and tertiary key colors.
  secondaryKey: UiColors.SECONDARY,
  tertiaryKey: UiColors.TERTIARY,
  // Tone chroma config and tone mapping is optional, if you do not add it
  // you get the config matching Flutter's Material 3 ColorScheme.fromSeed.
  tones: FlexTones.vivid(Brightness.light),
);

// Make a dark ColorScheme from the seeds.
final ColorScheme schemeDark = SeedColorScheme.fromSeeds(
  brightness: Brightness.dark,
  primaryKey: UiColors.PRIMARY,
  secondaryKey: UiColors.SECONDARY,
  tertiaryKey: UiColors.TERTIARY,
  tones: FlexTones.vivid(Brightness.dark),
);

class AppLauncher extends StatefulWidget {
  const AppLauncher({super.key});

  @override
  State<AppLauncher> createState() {
    return  _AppLauncherState();
  }
}

class _AppLauncherState  extends State<AppLauncher> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Widget _page =  Container();
  User? user;
  Utente? _utente;
  // PuntoVendita?  _puntoVendita;

  String? _errorMessage;

  Future<bool> _checkPermissions() async {
    // IOS
    // FIREBASE PUSH NOTIFICATION IOS
    if (Platform.isIOS) {
      firebaseMessagingPermission();
    }
    // ANDROID
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.request().isGranted) {
      } else {
        var status = await Permission.storage.status;
        if (status == PermissionStatus.granted) {
        } else {
          return false;
        }
      }
    }

    return true;
  }

  void firebaseMessagingPermission() {
    _firebaseMessaging.requestPermission(
        sound: true, badge: true, alert: true, provisional: false);
  }


  bool checkIfIsAdmin(Utente? u) {
    if (u != null) {
      return u.ruolo == 'admin' ? true : false;
    }
    else{
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    await _checkPermissions();
    _selectPage();
  }

  _selectPage() async {
    Widget page;

    ///TODO
    ///1 recuperare informazioni sull'utente e controllare se è amministratore
    ///2 andare alla pagina dell'amministratore
    ///3 andare alla pagine del cliente
    if (_utente != null) {
      if (!_utente!.confermato!) {
        page = _lockedPage();
      }
      (_utente!.ruolo == 'admin') ? page = ProdottiList() : page = ForgotPasswordScreen();
    } else {
      page = SignInScreen();
      // page = LoginForm();
    }
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //leviamo il banner pe gli screenshot
      debugShowCheckedModeBanner: false,
      title: 'BufalaBuona',
      theme: ThemeData.from(
        colorScheme: schemeLight,
        useMaterial3: true,
      )
          .copyWith(cardTheme: CardTheme(
        // surfaceTintColor: Colors.white,
      )

      ),
     


      // darkTheme: ThemeData.from(
      //   colorScheme: schemeDark,
      //   useMaterial3: true,
      // ),
      // theme: ThemeData.light(useMaterial3: true).copyWith(colorScheme: ColorScheme.fromSwatch(
      //     primarySwatch: CustomColors.primaryColor),
      //   bottomAppBarColor: CustomColors.primaryColor,
      //
      //   bottomAppBarTheme: const BottomAppBarTheme(color: Colors.blueGrey),),
      home: BufalaRouter(),
      onGenerateRoute: (settings) {
        if(settings.name=='/router'){
          return MaterialPageRoute(builder: (context)=>BufalaRouter());
        }
        if(settings.name =='/homeAdmin'){
          // return MaterialPageRoute(builder: (context) => HomeDispatcher(user: user!));
          return MaterialPageRoute(builder: (context)=>HomeAdmin(options: (settings.arguments as Map<String?,dynamic>)));
        }
        if(settings.name =='/homeNonConfermato'){
          // return MaterialPageRoute(builder: (context) => HomeDispatcher(user: user!));
          return MaterialPageRoute(builder: (context)=>ProfileUnauthorizedScreen(options: (settings.arguments as Map<String?,dynamic>)));
        }
        if(settings.name == '/home'){
          return MaterialPageRoute(builder: (context)=>Home(options: (settings.arguments as Map<String?,dynamic>)));
        }
        if(settings.name =='/signIn'){ return MaterialPageRoute(builder: (context) => SignInScreen());}
        // if(settings.name =='/signIn'){ return MaterialPageRoute(builder: (context) => LoginForm());}

        if(settings.name =='/signUp'){ return MaterialPageRoute(builder: (context) => SignUpScreen());}
        if(settings.name =='/forgotPassword'){ return MaterialPageRoute(builder: (context) => ForgotPasswordScreen());}
        if(settings.name =='/profile'){ return MaterialPageRoute(builder: (context) => ProfileScreen(options: (settings.arguments as Map<String?,dynamic>)));}
        if(settings.name =='/profile/changePassword'){ return MaterialPageRoute(builder: (context) => ChangePasswordScreen(options: (settings.arguments as Map<String?,dynamic>)));}
        if(settings.name == '/confirmedOrder'){return MaterialPageRoute(builder: (context)=> ConfirmedOrderScreen(options: (settings.arguments as Map<String?,dynamic>)));}
      },

    );
  }

  Widget _lockedPage() {
    return Scaffold(
        body: Container(
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [ Colors.red],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          child: SingleChildScrollView(
            child: Center(
              child:  Padding(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                child:  Column(
                  children: <Widget>[
                   const SizedBox(
                      height: 20,
                    ),
                    Image.asset(
                      'images/icons/logo_white_transparent.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.contain,
                    ),
                   const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'ATTENZIONE'),
                  const  SizedBox(
                      height: 20.0,
                    ),
                   const Text(
                        'Su questo telefono sono stati abilitati i permessi di root o è stato effettuato il Jailbreak.'
                            '\nPer ragioni di sicurezza l\'utilizzo dell\'Applicazione è interdetto su questo tipo di dispositivi.'
                            '\n\nUtilizzare un altro dispositivo',
//            Translation.of(this.context).trans("dumpfragment_message1"),
                        textAlign: TextAlign.center),
                    const SizedBox(
                      height: 40.0,
                    ),
                    MaterialButton(
                        minWidth: 250.0,
                        height: 48.0,
                        child: const Text('CHIUDI'),
                        onPressed: () => _closeApp())
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _closeApp() {
    if (Platform.isAndroid) {
      SystemNavigator.pop();
    } else if (Platform.isIOS) {
      exit(0);
    }
  }
}


Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    default:
      return MaterialPageRoute(
          builder: (_) => kIsWeb ? WebHomeScreen() : BufalaRouter());
  }
}