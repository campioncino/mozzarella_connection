import 'package:flutter/material.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/ui_icons.dart';
import '/components/auth_required_state.dart';
import '/utils/helpers.dart';

class ChangePasswordScreen extends StatefulWidget {
  final Map<String?, dynamic>? options;
  const ChangePasswordScreen({Key? key,  this.options}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePasswordScreen> {
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _passwordField = TextEditingController();

  final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

  String _password = '';
  bool _obscureText = true;
  bool _obscure2Text = true;

  Icon _eyeIcon = UiIcons.eyeSlash;
  Icon _eyeIcon2 = UiIcons.eyeSlash;

  Map<String?, dynamic>? _options;

  Future _onPasswordChangePress(BuildContext context) async {
    try {
      final form = formKey.currentState;

      if (form != null && form.validate()) {
        form.save();
        FocusScope.of(context).unfocus();

        final userAttributes = UserAttributes(password: _password);
        final response = await Supabase.instance.client.auth.updateUser(userAttributes);
        if (response == null) {
          throw 'Cambio Password fallito';
        }

        showMessage('Password aggiornata');

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/router', arguments:this.widget.options,
              (route) => false,
        );
        if (Navigator.canPop(context)) {
          _btnController.success();
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/', arguments:this.widget.options,
                (route) => false,
          );
        }
      }
    } catch (e) {
      showMessage(e.toString());
    } finally {
      _btnController.reset();
    }
  }

  void showMessage(String message) {
    final snackbar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(snackbar);
  }

  @override
  void initState() {
    super.initState();
    _options = this.widget.options;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backPressed,
      child: Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
        iconTheme: IconThemeData(
            color: Colors.white
        ),
        backgroundColor:Color(0xFF3BBAD5) ,
        title: const Text('Cambio Password',style: TextStyle(color: Colors.white),),
      ),
        body: Stack(
            children: <Widget>[ 
              SingleChildScrollView(
                child: Column(
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

                            Text("AInserisci una nuova password di almeno 6 caratteri",style: TextStyle(color: Colors.white,fontSize: 22),),
                            Expanded(child: Text("NUOVA PASSWORD!",style: TextStyle(color: Colors.white,fontSize: 35,fontWeight: FontWeight.w800),)),
                          ],
                        ),
                      ),
                    ),),

                  Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0,vertical: 25),
                          child: TextFormField(
                            onSaved: (value) => _password = value ?? '',
                            validator: (val) => validatePassword(val),
                            obscureText: _obscureText,
                            controller: _passwordField,
                            decoration:  InputDecoration(
                              suffixIcon: new IconButton(
                                  icon: _eyeIcon, iconSize: 18.0, onPressed: _toggle),
                              hintText: 'Nuova Password',
                            ),
                          ),
                        ),

                        // TextFormField(
                        //   onSaved: (value) => _password = value ?? '',
                        //   validator: (val) => validatePassword(val),
                        //   controller: _passwordField,
                        //   obscureText: true,
                        //   decoration: const InputDecoration(
                        //     hintText: 'Password',
                        //   ),
                        // ),
                        // Padding(
                        //   padding: const EdgeInsets.fromLTRB( 28.0, 45,28,0),
                        //   child: Text("Ripeti la nuova password"),
                        // ),
                        SizedBox(height: 40,),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28.0,vertical: 5),
                          child: TextFormField(
                            validator: (val) =>
                            val != _passwordField.text ? 'Non Corrispondente' : null,
                            obscureText: _obscure2Text,
                            decoration:  InputDecoration(
                              suffixIcon: new IconButton(
                                  icon: _eyeIcon, iconSize: 18.0, onPressed: _toggle2),
                              hintText: 'Ripeti Nuova Password',
                            ),
                          ),
                        ),
                        const SizedBox(height: 45.0),
                        RoundedLoadingButton(
                          borderRadius: 15,
                          color: Colors.green,
                          controller: _btnController,
                          onPressed: () {
                            _onPasswordChangePress(context);
                          },
                          child: const Text(
                            'Salva',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
                ],
            ),
              )],
        ),
      ),
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

  void _toggle2() {
    setState(() {
      _obscure2Text = !_obscure2Text;
      _obscure2Text
          ? _eyeIcon2 = UiIcons.eyeSlash
          : _eyeIcon2 = UiIcons.eye;
    });
  }

  Future<bool> backPressed() async {
    if(_options!=null){
      if(_options!['route']=='PROFILE'){
        Navigator.pop(context);
      }
    }else{
    Navigator.of(context).pushReplacementNamed('/signIn');}
    return true;
  }
}