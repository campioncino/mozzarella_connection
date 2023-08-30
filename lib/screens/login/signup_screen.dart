import 'package:bufalabuona/screens/login/confirmed_signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../model/utente.dart';
import '/components/auth_state.dart';
import '/utils/helpers.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _btnController =
  RoundedLoadingButtonController();

  String _email = '';
  String _password = '';
  String _username = '';
  String _fullName = '';
  String _phoneNumber = '';
  String _uuid ='';
  String _note='';
  bool _operatorePuntoVendita=true;

  Future _onSignUpPress(BuildContext context) async {
    final form = formKey.currentState;

    if (form != null && form.validate()) {
      form.save();
      FocusScope.of(context).unfocus();

      final response = await Supabase.instance.client.auth.signUp(emailRedirectTo: await authRedirectUri,
         email: _email, password: _password,data:{ 'username': _username,'phone_number': _phoneNumber,
            'full_name':_fullName,'note':_note, 'operatore_punto_vendita':_operatorePuntoVendita} );
      if(response.user!=null){
        Map<String,dynamic>? options = new Map();
        options={'authResponse': response};
        Navigator.pushReplacement(context, MaterialPageRoute( builder: (context) =>
        new ConfirmedSignupScreen(options: options,)));
        showMessage(
                "Per favore controlla la mail e segui le istruzioni per verificare il tuo indirizzo");
            _btnController.success();
      }
      // if (response.error != null) {
      //   showMessage('Registrazione Fallita: ${response.error!.message}');
      //   _btnController.reset();
      // } else if (response.data == null && response.user == null) {
      //   showMessage(
      //       "Per favore controlla la mail e segui le istruzioni per verificare il tuo indirizzo");
      //   _btnController.success();
      // } else {
      if(response.user!.emailConfirmedAt!=null){
        debugPrint("che vuoi fare?");
       // await  updateProfile(response.user);
      }
      // }
    }else{
      _btnController.reset();
    }
  }

  Future updateProfile(dynamic user) async {

    final updates = {
      'id' : user.id,
      'email':_email,
      'username': _username,
      'updated_at': DateTime.now().toString(),
      'phone_number': _phoneNumber,
      'full_name':_fullName
    };
    final response = await Supabase.instance.client
        .from('profiles')
        .upsert(updates).select()
        ;
    if (response == null) {
      throw "Update profile failed: ${response.error!.message}";
    }else{
      Map<String,dynamic> options = {'user':user};
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/profile',arguments: options,
          (route) => false,
    );}
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: const Text('Registrati'),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    onSaved: (value) => _email = value ?? '',
                    validator: (val) => validateEmail(val),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'Inserisci il tuo indirizzo mail',
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    onSaved: (value) => _password = value ?? '',
                    validator: (val) => validatePassword(val),
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Password',
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    onSaved: (value) => _username = value ?? '',
                    inputFormatters: [FilteringTextInputFormatter(RegExp(r'[a-zA-Z0-9]'), allow: true)],
                    validator: (val) => validateText(val),
                    decoration: const InputDecoration(
                      hintText: 'Username',
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    onSaved: (value) => _fullName = value ?? '',
                    validator: (val) => validateText(val),
                    decoration: const InputDecoration(
                      hintText: 'Nome e Cognome',
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    onSaved: (value) => _phoneNumber = value ?? '',
                    validator: (val) => validateText(val),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'Numero Telefono',
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                SwitchListTile(
                    title: Text("Operatore Punto Vendita"),
                    subtitle: Text("Se si sta richiedendo l'account per poter effettuare ordini per conto di un punto vendita"),
                    value: _operatorePuntoVendita,
                    inactiveTrackColor: Colors.grey[300],
                    activeColor: Colors.green,
                    onChanged: (bool value) {
                      setState(() {
                        _operatorePuntoVendita = value;
                      });
                      }),
                const SizedBox(height: 15,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextFormField(
                    maxLines: 2,
                    onSaved: (value) => _note = value ?? '',
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      hintText: 'Note Aggiuntive',
                    ),
                  ),
                ),
                const SizedBox(height: 55.0),
                // RoundedLoadingButton(
                //   borderRadius: 15,
                //   color: Colors.green,
                //   controller: _btnController,
                //   onPressed: () {
                //     _onSignUpPress(context);
                //   },
                //   child: const Text(
                //     'Registrati',
                //     style: TextStyle(fontSize: 20, color: Colors.white),
                //   ),
                // )
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton:RoundedLoadingButton(
        borderRadius: 15,
        color: Colors.green,
        controller: _btnController,
        onPressed: () {
          try{
          _onSignUpPress(context);}catch (Error) {
            _btnController.reset();
          }
        },
        child: const Text(
          'Registrati',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ) ,
    );
  }
}