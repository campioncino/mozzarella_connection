import 'dart:async';

import 'package:bufalabuona/main.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';


class BufalaRouter extends StatefulWidget {
  const BufalaRouter({Key? key}) : super(key: key);

  @override
  State<BufalaRouter> createState() => _BufalaRouterState();
}

class _BufalaRouterState extends State<BufalaRouter> {
  Utente? _utente;
  PuntoVendita? _puntoVendita;

  @override
  Widget build(BuildContext context) {
    FlutterRingtonePlayer.play(fromAsset: "assets/sounds/ringbellCow.mp3");
    return  Scaffold(
        backgroundColor: themeColor,
      // backgroundColor: Colors.orangeAccent,



        body: Container(
            // decoration: BoxDecoration(gradient:  RadialGradient(
            //   colors: [Color(0xffd8f3ff), Color(0xFF3BBAD5)],
            //   center: Alignment.bottomCenter,
            //   radius: 0.8,
            // )),
            height: double.infinity,
            width: double.infinity,
            // child: Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.center,children: [
          child:Stack(children: [
              Container(color: Colors.white,
              height: MediaQuery.of(context).size.height/2,),
              Center(child: Image.asset("assets/images/bb2.png", fit: BoxFit.fill,)),
              // Positioned(
              //   left: 20,
              //   right: 20,
              //   bottom: MediaQuery.of(context).size.height/5,
              //   // top: MediaQuery.of(context).size.height/7,
              //   child: Column(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Text("AZIENDA AGRICOLA",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400,fontSize: 18),),
              //       Text("GIANCARLO D'ANGELO",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w400,fontSize: 22))
              //     ],
              //   ),
              // ),

            ],)


        ));
  }

  bool _redirectCalled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  Future<void> _redirect() async {

    await Future.delayed(const Duration(seconds: 5), (){});
    if (_redirectCalled || !mounted) {
      return;
    }

    _redirectCalled = true;
    final session = supabase.auth.currentSession;
    if (session != null && session.user!=null) {
      // Navigator.of(context).pushReplacementNamed('/router');
      _utente = await _loadUtente(session.user.id);
      if(_utente==null){
        Navigator.of(context).pushReplacementNamed('/signIn');
      }else{
      initUtente();}
    } else {
      Navigator.of(context).pushReplacementNamed('/signIn');
    }
  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // initUtente();
    _redirect();
  }

  Future<void> initUtente() async{
    await navigationRouting(_utente!);
  }

  Future<void> navigationRouting(Utente? utente) async {
    if(utente!.confermato!){
      if(utente.ruolo=='admin'){
        Map<String,dynamic>? options = new Map();
        options={'utente':utente};
        Navigator.pushNamedAndRemoveUntil(context, '/homeAdmin', (route) => false, arguments: options);
      }else{
        _puntoVendita = await _loadPuntoVendita(_utente!.puntoVendita!);
        Map<String,dynamic>? options = new Map();
        options={'puntoVendita':_puntoVendita,'utente':utente};
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false,arguments: options);
      }
    }else{
      Map<String,dynamic>? options = new Map();
      options={'utente':utente};
      Navigator.pushNamedAndRemoveUntil(context, '/homeNonConfermato', arguments: options,(route) => false);
    }
  }

  Future<Utente?> _loadUtente(String userId) async {
    Utente? utente;
    try {
      final response = await supabase
          .from('utenti')
          .select()
          .eq('profile_id', userId)
          .maybeSingle()
      ;
      // if (response.error != null) {
      //   throw "Load profile failed: ${response.error!.message}";
      // } else {
        utente = Utente.fromJson(response);
      // }
    } catch (e) {
      debugPrint("error :${e.toString()}");
    }
    return utente;
  }

  Future<PuntoVendita?> _loadPuntoVendita(int id) async {
    PuntoVendita? puntoVendita;
    try {
      final response = await supabase
          .from('punti_vendita')
          .select()
          .eq('id', id)
          .maybeSingle();
      puntoVendita = PuntoVendita.fromJson(response);
    } catch (e) {
      debugPrint("error :${e.toString()}");
    }
    return puntoVendita;
  }

  @override
  void dispose() {
    super.dispose();
  }


}
