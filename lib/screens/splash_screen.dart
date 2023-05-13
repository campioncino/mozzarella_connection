import 'dart:async';

import 'package:bufalabuona/utils/network_connectivity.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';


class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {

  Map _source = {ConnectivityResult.none: false};
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  bool _isConnected = false;

  Timer? recoverSessionTimer;


  bool _redirectCalled = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (_redirectCalled || !mounted) {
      return;
    }

    _redirectCalled = true;
    final session = supabase.auth.currentSession;
    if (session != null) {
      Navigator.of(context).pushReplacementNamed('/router');
    } else {
      Navigator.of(context).pushReplacementNamed('/signIn');
    }
  }

  @override
  void initState() {
    super.initState();

    /// a timer to slow down session restore
    /// If not user can't really see the splash screen
    // const _duration = Duration(seconds: 2);
    //
    // recoverSessionTimer = Timer(_duration, () {
    //   recoverSupabaseSession();
    // });
  }

  /// on received auth deeplink, we should cancel recoverSessionTimer
  /// and wait for auth deep link handling result
  @override
  void onReceivedAuthDeeplink(Uri uri) {
    if (recoverSessionTimer != null) {
      recoverSessionTimer!.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator()
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     Image.asset(
        //       "assets/images/logo-dark.png",
        //     ),
        //   ],
        // ),
      ),
    );
  }

}