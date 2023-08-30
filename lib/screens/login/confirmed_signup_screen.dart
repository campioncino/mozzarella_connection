
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../utils/ui_icons.dart';

class ConfirmedSignupScreen extends StatefulWidget {

  final Map<String?, dynamic>? options;
  const ConfirmedSignupScreen({Key? key,required this.options}) : super(key: key);

  @override
  State<ConfirmedSignupScreen> createState() => _ConfirmedSignupScreenState();
}

class _ConfirmedSignupScreenState extends State<ConfirmedSignupScreen> {

  final RoundedLoadingButtonController _submitController = RoundedLoadingButtonController();
  final postgresDateFormatter = new DateFormat('yyyy-MM-dd');
  final dateFormatter = new DateFormat('dd-MM-yyyy');

  AuthResponse? _response;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _response = this.widget.options?['authResponse'];
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
        child: Scaffold(
          floatingActionButton : RoundedLoadingButton(onPressed: _goLogin,
              borderRadius: 15,
              color: Colors.amberAccent,
              controller: _submitController,child: Text("Torna al login",style: TextStyle(fontSize: 22,color: Colors.black),)),
          body: Stack(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Align(alignment:Alignment.bottomLeft,child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    UiIcons.confirmed,
                    Text("Ciao ${_response!.user?.userMetadata?['full_name']??''},",style: TextStyle(color: Colors.white,fontSize: 22),),
                    Text("richiesta effettuata!",style: TextStyle(color: Colors.white,fontSize: 40,fontWeight: FontWeight.w800),),
                  ],
                ),
              )),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height/7*3,
              color: Color(0xFF3BBAD5),
            ),
            dettaglioOrdine() ],
        ),
      ],
    ),));
  }

  Widget dettaglioOrdine(){
    return Container(child: Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        SizedBox(height: 10,),
        RichText(text: TextSpan(text:"Grazie per aver effettuato l'iscrizione.\nTi abbiamo inviato una email all'indirizzo ${_response!.user!.email??''} indicato per confermare la tua richiesta! Per favore controlla la mail (anche nello spam) e segui le istruzioni per verificare il tuo indirizzo",style: TextStyle(fontWeight: FontWeight.w400,color: Colors.black54,fontSize: 18))),
        ],),
    ),);
  }

  _goLogin(){
    Navigator.of(context).pushReplacementNamed('/signIn');
  }
}
