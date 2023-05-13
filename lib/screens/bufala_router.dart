import 'package:bufalabuona/main.dart';
import 'package:bufalabuona/model/punto_vendita.dart';
import 'package:bufalabuona/model/utente.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Router extends StatefulWidget {
  const Router({Key? key}) : super(key: key);

  @override
  State<Router> createState() => _RouterState();
}

class _RouterState extends State<Router> {
  Utente? _utente;
  PuntoVendita? _puntoVendita;

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final session = supabase.auth.currentSession;
     _loadUtente(session!.user.id);
     // _loadPuntoVendita(_utente!.puntoVendita);
  }

  Future<Utente?> _loadUtente(String userId) async {
    Utente? utente;
    try {
      final response = await Supabase.instance.client
          .from('utenti')
          .select()
          .eq('profile_id', userId)
          .maybeSingle()
      ;
      if (response.error != null) {
        throw "Load profile failed: ${response.error!.message}";
      } else {
        utente = Utente.fromJson(response.data);
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
          .select()
          .eq('id', id)
          .maybeSingle()
      ;
      if (response.error != null) {
        throw "Load PuntoVenditaFailed failed: ${response.error!.message}";
      } else {
        puntoVendita = PuntoVendita.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("error :${e.toString()}");
    }
    return puntoVendita;
  }
}
