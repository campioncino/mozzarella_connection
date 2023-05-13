import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

import '/components/auth_state.dart';
import '/utils/helpers.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignInScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _signInEmailController =
  RoundedLoadingButtonController();
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

      final response = await Supabase.instance.client.auth.signInWithPassword(email: _email, password: _password);
      // if (response != null) {
      //   // showMessage(response.session!.message);
      //   _signInEmailController.reset();
      // } else {
response;
        if(response.user!=null){
          utente =await _loadUtente(response.user!.id);
          if(utente!=null && utente!.ruolo == 'admin' && utente!.confermato!){
            Map<String,dynamic>? options = new Map();
            options={'utente':utente};
            Navigator.pushNamedAndRemoveUntil(context, '/homeAdmin', (route) => false, arguments: options);
          }
          if(utente!=null && !utente!.confermato!){
            Navigator.pushNamedAndRemoveUntil(context, '/homeNonConfermato', (route) => false);
          }
          if(utente!=null && utente!.confermato! && utente!.ruolo != 'admin'){
            Map<String,dynamic>? options = new Map();
            puntoVendita = await _loadPuntoVendita(utente!.puntoVendita!);
            options={'puntoVendita':puntoVendita,'utente':utente};
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false,arguments: options);
          }
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
      appBar: AppBar(
        title: const Text('Accedi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 25.0),
              TextFormField(
                onSaved: (value) => _email = value ?? '',
                validator: (val) => validateEmail(val),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'inserisci il tuo indirizzo mail',
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                onSaved: (value) => _password = value ?? '',
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
              ),
              const SizedBox(height: 15.0),
              RoundedLoadingButton(
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
              const SizedBox(height: 15.0),
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
              const SizedBox(height: 15.0),
              TextButton(
                onPressed: () {
                  // stopAuthObserver();
                  Navigator.pushNamed(context, '/forgotPassword');
                      // .then((_) => startAuthObserver());
                },
                child: const Text("Password Dimenticata ?"),
              ),
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
      ),
    );
  }
}