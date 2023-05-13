// import 'package:bufalabuona/data/punti_vendita_rest_service.dart';
// import 'package:bufalabuona/model/punto_vendita.dart';
// import 'package:bufalabuona/model/utente.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase/supabase.dart' as supabase;
// import 'package:supabase_flutter/supabase_flutter.dart';
//
// class AuthState extends StatefulWidget {
//   Utente? utente;
//   PuntoVendita? puntoVendita;
//
//   @override
//   void onUnauthenticated() {
//     Navigator.pushNamedAndRemoveUntil(context, '/signIn', (route) => false);
//   }
//
//   @override
//   Future<void> onAuthenticated(supabase.Session session) async {
//     session;
//     if(session.user!=null){
//     utente =await _loadUtente(session.user!.id);
//     if(utente!=null && utente!.ruolo!='admin'){
//       _loadPuntoVendita(utente!.puntoVendita!);
//     }
//       if(utente!=null && utente!.ruolo == 'admin' && utente!.confermato!){
//         Map<String,dynamic>? options = new Map();
//         options={'utente':utente};
//       Navigator.pushNamedAndRemoveUntil(context, '/homeAdmin', (route) => false, arguments: options);
//       }
//       if(utente!=null && !utente!.confermato!){
//         Navigator.pushNamedAndRemoveUntil(context, '/homeNonConfermato', (route) => false);
//       }
//       if(utente!=null && utente!.confermato! && utente!.ruolo != 'admin'){
//         puntoVendita=await _loadPuntoVendita(utente!.puntoVendita!);
//         Map<String,dynamic>? options = new Map();
//         options['utente']=utente;
//         options['puntoVendita']=puntoVendita;
//         Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false, arguments: options);
//       }
//     }
//   }
//
//   @override
//   void onPasswordRecovery(supabase.Session session) {
//     Navigator.pushNamedAndRemoveUntil(
//         context, '/profile/changePassword', (route) => false);
//   }
//
//   @override
//   void onErrorAuthenticating(String message) {
//     print('***** onErrorAuthenticating: $message');
//   }
//
//   Future<Utente?> _loadUtente(String userId) async {
//     Utente? utente;
//     try {
//       final response = await Supabase.instance.client
//           .from('utenti')
//           .select(
//       )
//           .eq('profile_id', userId)
//           .maybeSingle()
//           ;
//       if (response.error != null) {
//         throw "Load profile failed: ${response.error!.message}";
//       } else {
//         utente = Utente.fromJson(response.data);
//       }
//     } catch (e) {
//       debugPrint("error loadin utente :${e.toString()}");
//     }
//     return utente;
//   }
//
//
//   Future<PuntoVendita?> _loadPuntoVendita(int id) async {
//     try {
//       final response = await Supabase.instance.client
//           .from('punti_vendita')
//           .select(
//       )
//           .eq('id', id)
//           .maybeSingle()
//           ;
//       if (response.error != null) {
//         throw "Load PuntoVendita failed: ${response.error!.message}";
//       } else {
//         puntoVendita = PuntoVendita.fromJson(response.data);
//       }
//     } catch (e) {
//       debugPrint("error :${e.toString()}");
//     }
//     return puntoVendita;
//   }
//
//   // Future<PuntoVendita?> _loadPuntoVendita(int i) async {
//   //     return await PuntiVenditaRestService.internal(context).getPuntoVendita(utente!.puntoVendita!);
//   // }
//
// }