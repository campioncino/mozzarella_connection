import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:bufalabuona/utils/app_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
// import 'package:supabase/supabase.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';

import '../../main.dart';
import '../../utils/ui_icons.dart';
import '/components/auth_state.dart';
import '/utils/helpers.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Icon _eyeIcon = UiIcons.eyeSlash;
  bool _obscureText = true;
  final RoundedLoadingButtonController _signInEmailController =
  RoundedLoadingButtonController();
  final RoundedLoadingButtonController _signInGoogleController = RoundedLoadingButtonController();
  final RoundedLoadingButtonController _magicLinkController =
  RoundedLoadingButtonController();
  final RoundedLoadingButtonController _githubSignInController =
  RoundedLoadingButtonController();

  String _email = '';
  String _password = '';
  Utente? utente;
  PuntoVendita? puntoVendita;

  @override
  void onErrorAuthenticating(String message) {
    showMessage(message);
    _githubSignInController.reset();
  }

  Future _onSignInPress(BuildContext context) async {
    final form = formKey.currentState;

    if (form != null && form.validate()) {
      form.save();
      FocusScope.of(context).unfocus();

     try {
       final response = await Supabase.instance.client.auth.signInWithPassword(
           email: _email, password: _password);
       if (response.user != null) {
         await AppUtils.storePassword(_password);
         utente = await _loadUtente(response.user!.id);
         if (utente != null && utente!.ruolo == 'admin' &&
             utente!.confermato!) {
           Map<String, dynamic>? options = new Map();
           options = {'utente': utente};
           Navigator.pushNamedAndRemoveUntil(
               context, '/homeAdmin', (route) => false, arguments: options);
         }
         if (utente != null && !utente!.confermato!) {
           Map<String,dynamic>? options = new Map();
           options={'utente':utente};
           Navigator.pushNamedAndRemoveUntil(
               context, '/homeNonConfermato', (route) => false, arguments: options);
         }
         if (utente != null && utente!.confermato! &&
             utente!.ruolo != 'admin') {
           Map<String, dynamic>? options = new Map();
           puntoVendita = await _loadPuntoVendita(utente!.puntoVendita!);
           options = {'puntoVendita': puntoVendita, 'utente': utente};
           Navigator.pushNamedAndRemoveUntil(
               context, '/home', (route) => false, arguments: options);
         }
       }
     }catch (e){
       showMessage("impossibile accedere ${e.toString()}");
       _signInEmailController.reset();
     }

    } else {
      _signInEmailController.reset();
    }
  }

  Future<Utente?> _loadUtente(String userId) async {
    Utente? utente;
    try {
      final response = await Supabase.instance.client
          .from('utenti')
          .select(
      )
          .eq('profile_id', userId)
          .maybeSingle()
          ;
      if (response != null) {
        utente = Utente.fromJson(response);

      } else {
        throw "Load profile failed: ${response.error!.message}";
      }
    } catch (e) {
      debugPrint("error :${e.toString()}");
    }
    return utente;
  }

  Future<PuntoVendita?> _loadPuntoVendita(int id) async {
    PuntoVendita? puntoVendita;
    try {
      final response = await Supabase.instance.client
          .from('punti_vendita')
          .select(
      )
          .eq('id', id)
          .maybeSingle()
          ;
      if (response != null) {
        puntoVendita = PuntoVendita.fromJson(response);

      } else {
        throw "Load PuntoVenditaFailed failed: ${response.error!.message}";
      }
    } catch (e) {
      debugPrint("error :${e.toString()}");
    }
    return puntoVendita;
  }


  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: const Text('Accedi'),
      // ),
      body:Stack( children: <Widget>[
         SingleChildScrollView(
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
               Container(
                 width: MediaQuery.of(context).size.width,
                 height: MediaQuery.of(context).size.height/8*3,
                 color: Color(0xFF3BBAD5),
                 child: Align(
                   alignment:Alignment.bottomLeft,
                   child: Padding(
                     padding: const EdgeInsets.all(18.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisAlignment: MainAxisAlignment.end,
                       children: [
                         UiIcons.signIn,
                         SizedBox(height: 20,),
                         Text("Accedi inserendo la tua email e la tua password",style: TextStyle(color: Colors.white,fontSize: 22),),
                         Text("LOGIN!",style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w800),),
                       ],
                     ),
                   ),
                 ),),
              Padding(
            padding: const EdgeInsets.all(18.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 30,),
                  TextFormField(
                    onSaved: (value) => _email = value ?? '',
                    validator: (val) => validateEmail(val),
                    keyboardType: TextInputType.emailAddress,
                    decoration:  InputDecoration(
                      // enabledBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(50.0),
                      //   borderSide: BorderSide(
                      //       width: 1, color: Colors.green),
                      // ),
                      hintText: 'inserisci il tuo indirizzo mail',
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextFormField(
                    onSaved: (value) => _password = value ?? '',
                    obscureText: _obscureText,
                    decoration:  InputDecoration(
                      // enabledBorder: OutlineInputBorder(
                      //   borderRadius: BorderRadius.circular(50.0),
                      //   borderSide: BorderSide(
                      //       width: 1, color: Colors.green),
                      // ),
                      suffixIcon: new IconButton(
                          icon: _eyeIcon, iconSize: 18.0, onPressed: _toggle),
                      hintText: 'Password',
                    ),
                  ),
                  SizedBox(height:12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // stopAuthObserver();
                        Navigator.pushNamed(context, '/forgotPassword');
                        // .then((_) => startAuthObserver());
                      },
                      child: const Text("Password Dimenticata ?",style: TextStyle(fontSize: 12),),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  FittedBox(
                    fit: BoxFit.fill,
                    child: RoundedLoadingButton(
                      borderRadius: 15,
                      color: Colors.green,
                      controller: _signInEmailController,
                      onPressed: () {
                        _onSignInPress(context);
                      },
                      child: const Text(
                        'Accedi',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25.0),
                  divider('o'),
                  const SizedBox(height: 25.0),
                  // FittedBox(
                  //   fit: BoxFit.fill,
                  //   child: RoundedLoadingButton(
                  //     borderRadius: 15,
                  //     color: Colors.white,
                  //     controller: _signInGoogleController,
                  //     onPressed: ()=> signInWithGoogle(),
                  //     child: supabase.auth.currentUser!= null ? Text(supabase.auth.currentUser.toString()) : Row(
                  //       crossAxisAlignment: CrossAxisAlignment.end,
                  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //       children: [
                  //         ClipRect(child: Image.asset('assets/images/google.png',height: 30,)),
                  //         SizedBox(width: 10,),
                  //         const Text(
                  //           'Accedi con Google',
                  //           style: TextStyle(fontSize: 20, color: Colors.black54),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  // RoundedLoadingButton(
                  //   color: Colors.green,
                  //   controller: _magicLinkController,
                  //   onPressed: () {
                  //     _onMagicLinkPress(context);
                  //   },
                  //   child: const Text(
                  //     'Send magic link',
                  //     style: TextStyle(fontSize: 20, color: Colors.white),
                  //   ),
                  // ),
                  // const SizedBox(height: 15.0),
                  // RoundedLoadingButton(
                  //   color: Colors.black,
                  //   controller: _githubSignInController,
                  //   onPressed: () {
                  //     _githubSigninPressed(context);
                  //   },
                  //   child: const Text(
                  //     'Github Login',
                  //     style: TextStyle(fontSize: 20, color: Colors.white),
                  //   ),
                  // ),
                  const SizedBox(height: 25.0),
                  TextButton(
                    onPressed: () {
                      // stopAuthObserver();
                      Navigator.pushNamed(context, '/signUp');
                          // .then((_) => startAuthObserver());
                    },
                    child: const Text("Non hai un Account ? Registrati"),
                  ),
                ],
              ),
            ),
        )
        ]),
         )
      ]),
    );
  }

  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
      _obscureText
          ? _eyeIcon = UiIcons.eyeSlash
          : _eyeIcon = UiIcons.eye;
    });
  }


  /// Function to generate a random 16 character string.
  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  Future<AuthResponse> signInWithGoogle() async{
    // Just a random string
    final rawNonce = _generateRandomString();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    /// TODO: update the client ID with your own
    ///
    /// Client ID that you registered with Google Cloud.
    /// You will have two different values for iOS and Android.
    const clientAndroidId = '70115041987-5gjk4ta9oa9ocat7qbc8dsdrgp07flot.apps.googleusercontent.com';
    const clientIosId = '70115041987-cm664c2q85j9ji8qei6gb4f3a89envs3.apps.googleusercontent.com';

    final clientId = Platform.isIOS ? clientIosId : clientAndroidId;
    // /// reverse DNS form of the client ID + `:/` is set as the redirect URL
    // final redirectUrl = '${clientId.split('.').reversed.join('.')}:/';

    /// Fixed value for google login
    const discoveryUrl = 'https://accounts.google.com/.well-known/openid-configuration';

    const applicationId = 'com.aziendaagricoladangelo.bufalabuona';
    const redirectUrl = '$applicationId:/google_auth';
    final appAuth = FlutterAppAuth();

    // authorize the user by opening the concent page
    final result = await appAuth.authorize(
      AuthorizationRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        nonce: hashedNonce,
        scopes: [
          'openid',
          'email',
        ],
      ),
    );

    if (result == null) {
      throw 'No result';
    }

    // Request the access and id token to google
    final tokenResult = await appAuth.token(
      TokenRequest(
        clientId,
        redirectUrl,
        authorizationCode: result.authorizationCode,
        discoveryUrl: discoveryUrl,
        codeVerifier: result.codeVerifier,
        nonce: result.nonce,
        scopes: [
          'openid',
          'email',
        ],
      ),
    );

    final idToken = tokenResult?.idToken;

    if (idToken == null) {
      throw 'No idToken';
    }

    _signInGoogleController.stop();

    return Supabase.instance.client.auth.signInWithIdToken(
      provider: Provider.google,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  Widget divider(String text){
    return Row(children: <Widget>[
      Expanded(
        child: new Container(
            margin: const EdgeInsets.only(left: 0.0, right: 20.0),
            child: Divider(
              height: 36,
            )),
      ),
      Text(text),
      Expanded(
        child: new Container(
            margin: const EdgeInsets.only(left: 20.0, right: 0.0),
            child: Divider(
              height: 36,
            )),
      ),
    ]);
  }
}