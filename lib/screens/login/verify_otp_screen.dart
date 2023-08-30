import 'dart:async';

import 'package:bufalabuona/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/ui_icons.dart';
import '/components/auth_state.dart';
import '/utils/helpers.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({Key? key,required this.email}) : super(key: key);


  @override
  _VerifyOtpScreenState createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  Session? session;
  User? user;
  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();
  TextEditingController textEditingController = TextEditingController();

  String _email = '';

  String? _otp;

  @override
  void initState() {
    debugPrint("call initstate forgotPassword");
    _email=this.widget.email;
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


  Future _onOtpRecoverPress(BuildContext context) async {
    final form = formKey.currentState;
    try {
      if (form != null && form.validate()) {
        form.save();
        FocusScope.of(context).unfocus();


        final AuthResponse res = await supabase.auth.verifyOTP(
          type: OtpType.recovery,
          token: _otp!,
          email: _email,
        );
        session = res.session;
        user = res.user;
        _btnController.success();
      }else{
        _btnController.reset();
      }
      if (session != null) {
        Map<String, dynamic> options = new Map();
        Navigator.pushNamedAndRemoveUntil(
            context, '/profile/changePassword', (route) => false,
            arguments: options);
      }
    }catch(e){

      _btnController.reset();
      showMessage("OOPS qualcosa è andato storto!");
    }
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backPressed,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
                          Text("Accedi inserendo il codice OTP ricevuto via email",style: TextStyle(color: Colors.white,fontSize: 22),),
                          Text("OTP!",style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w800),),
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
                      // Padding(
                      //   padding: const EdgeInsets.all(28.0),
                      //   child: TextFormField(
                      //     onSaved: (value) => _otp = value ?? '',
                      //     validator: (val) => validatePassword(val),
                      //     keyboardType: TextInputType.text,
                      //     decoration: const InputDecoration(
                      //       hintText: 'Inserisci OTP di 6 cifre',
                      //     ),
                      //   ),
                      // ),
                      PinCodeTextField(
                        validator: (val) => validatePassword(val),
                        appContext: context,
                        length: 6,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(8),
                          inactiveColor: Colors.white70,
                          inactiveFillColor: Colors.orangeAccent[100],
                          fieldHeight: 60,
                          fieldWidth: 50,
                          activeFillColor: Colors.white,
                            selectedBorderWidth: 2,
                            selectedColor: Colors.green,
                            // selectedColor: Color(0xFF3BBAD5),
                          selectedFillColor: Colors.grey[200]
                          // selectedFillColor: Colors.green.shade100
                        ),
                        animationDuration: Duration(milliseconds: 300),
                        enableActiveFill: true,
                        errorAnimationController: errorController,
                        controller: textEditingController,
                        onCompleted: (v) {
                          print("Completed");
                        },
                        onChanged: (value) {
                          print(value);
                          setState(() {
                            _otp = value;
                          });
                        },
                        beforeTextPaste: (text) {
                          print("Allowing to paste $text");
                          //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                          //but you can show anything you want here, like your pop up saying wrong paste format or etc
                          return true;
                        },
                      ),
                      const SizedBox(height: 35.0),
                      RoundedLoadingButton(
                        borderRadius: 15,
                        color: Colors.green,
                        controller: _btnController,
                        onPressed: () {
                          _onOtpRecoverPress(context);
                        },
                        child: const Text(
                          'Conferma',
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
      ),
    );
  }

  Future<bool> backPressed() async {
    Navigator.of(context).pushReplacementNamed('/signIn');
    return true;
  }
}