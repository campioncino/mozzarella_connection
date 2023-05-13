import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase/supabase.dart' as supabase;
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future _onSignUpPress(BuildContext context) async {
    final form = formKey.currentState;

    if (form != null && form.validate()) {
      form.save();
      FocusScope.of(context).unfocus();

      final response = await Supabase.instance.client.auth.signUp(emailRedirectTo: await authRedirectUri,
         email: _email, password: _password);
      // if (response.error != null) {
      //   showMessage('Registrazione Fallita: ${response.error!.message}');
      //   _btnController.reset();
      // } else if (response.data == null && response.user == null) {
      //   showMessage(
      //       "Per favore controlla la mail e segui le istruzioni per verificare il tuo indirizzo");
      //   _btnController.success();
      // } else {
       await  updateProfile(response.user);
      // }
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
        .upsert(updates)
        ;
    if (response.error != null) {
      throw "Update profile failed: ${response.error!.message}";
    }else{
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/profile',
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
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Form(
          key: formKey,
          child: Column(
            children: <Widget>[
              const SizedBox(height: 15.0),
              TextFormField(
                onSaved: (value) => _email = value ?? '',
                validator: (val) => validateEmail(val),
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Inserisci il tuo indirizzo mail',
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                onSaved: (value) => _password = value ?? '',
                validator: (val) => validatePassword(val),
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: 'Password',
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                onSaved: (value) => _username = value ?? '',
                validator: (val) => validatePassword(val),
                decoration: const InputDecoration(
                  hintText: 'Username',
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                onSaved: (value) => _fullName = value ?? '',
                validator: (val) => validatePassword(val),
                decoration: const InputDecoration(
                  hintText: 'Nome e Cognome',
                ),
              ),
              const SizedBox(height: 15.0),
              TextFormField(
                onSaved: (value) => _phoneNumber = value ?? '',
                validator: (val) => validatePassword(val),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Numero Telefono',
                ),
              ),
              const SizedBox(height: 35.0),
              RoundedLoadingButton(
                color: Colors.green,
                controller: _btnController,
                onPressed: () {
                  _onSignUpPress(context);
                },
                child: const Text(
                  'Registrati',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}