import 'package:bufalabuona/main.dart';
import 'package:bufalabuona/screens/login/verify_otp_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/ui_icons.dart';
import '/components/auth_state.dart';
import '/utils/helpers.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final RoundedLoadingButtonController _btnController =
  RoundedLoadingButtonController();

  String _email = '';

  @override
  void initState() {
    debugPrint("call initstate forgotPassword");
    super.initState();
    final _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        //qua andiamo a reset password
        Map<String,dynamic> options = {};
        Navigator.pushNamedAndRemoveUntil(context, '/profile/changePassword', (route) => false, arguments: options);
      }
    });
    _authSubscription.cancel();
  }


  Future _onPasswordRecoverPress(BuildContext context) async {
    final form = formKey.currentState;

    if (form != null && form.validate()) {
      form.save();
      FocusScope.of(context).unfocus();

      final response = await supabase.auth.resetPasswordForEmail(_email,redirectTo:await authRedirectUri);
      // final response = await supabase.auth.resetPasswordForEmail(_email,
      //     redirectTo: kIsWeb
      //         ? null
      //         : 'io.supabase.flutterdemo://login-callback');

        showMessage('Ti abbiamo inviato il codice sulla tua mail');
        _btnController.success();
      Navigator.push(context, MaterialPageRoute(
          builder: (context) =>
          new VerifyOtpScreen(email: _email)));

    }else{
      _btnController.reset();
    }
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
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        backgroundColor:Color(0xFF3BBAD5) ,
        title: const Text('Recupera Password',style: TextStyle(color: Colors.white),),
      ),
      body: Stack(
          children: <Widget>[ Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height/10*3,
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
                        Text("Recupera la password, inserisci la tua email",style: TextStyle(color: Colors.white,fontSize: 22),),
                        Text("RESET!",style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w800),),
                      ],
                    ),
                  ),
                ),),

              Padding(
              padding: const EdgeInsets.all(18.0),
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
                        hintText: 'Inserisci il tuo indirizzo mail',
                      ),
                    ),
                    const SizedBox(height: 35.0),
                    RoundedLoadingButton(
                      borderRadius: 15,
                      color: Colors.green,
                      controller: _btnController,
                      onPressed: () {
                        _onPasswordRecoverPress(context);
                      },
                      child: const Text(
                        'Invio istruzioni reset password',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
        ),
            ],
          )],
      ),
    );
  }
}