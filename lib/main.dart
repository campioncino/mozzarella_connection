import 'dart:async';
import 'dart:isolate';

import 'package:bufalabuona/app_config.dart';
import 'package:bufalabuona/app_launcher.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'configure_nonweb.dart' if (dart.library.html) 'configure_web.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.

  if(kIsWeb){
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyDy9koGQ4-Oxq5oiaZyLBN3bHgJDNi0_Z4",
          authDomain: "mozzarella-connection-a8589.firebaseapp.com",
          projectId: "mozzarella-connection-a8589",
          storageBucket: "mozzarella-connection-a8589.appspot.com",
          messagingSenderId: "675275977106",
          appId: "1:675275977106:web:64cb27a4a7f42fcc3b514b",
          measurementId: "G-M99EMQ5ZFC"
      ),
    );
  }else{
  await Firebase.initializeApp();}
  debugPrint("Handling a background message: ${message.messageId}\nbackground message ${message.notification!.body}");
}


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(url:  dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);  /// Initialize Crash report

  if (!kIsWeb) {
    if (kDebugMode) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  }
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  // await configureApp();
  var configuredApp = new AppConfig(
    child: new AppLauncher(),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

if(!kIsWeb) {
  // Errors outside of Flutter
  Isolate.current.addErrorListener(RawReceivePort((List<dynamic> pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last as StackTrace,
    );
  }).sendPort);
}


  runZonedGuarded(() {
    // if(!kIsWeb){
    runApp(ProviderScope(child: configuredApp));
  // }

  }, FirebaseCrashlytics.instance.recordError);
}

final supabase = Supabase.instance.client;

bool isAuthenticated() {
  return supabase.auth.currentUser != null;
}

bool isUnauthenticated() {
  return isAuthenticated() == false;
}

final themeColor = Color(0xFFbcdeea);


Future<void> refreshSession() async {
  if (isAuthenticated() && supabase.auth.currentSession != null) {
    final expiresAt = DateTime.fromMillisecondsSinceEpoch(
        supabase.auth.currentSession!.expiresAt! * 1000);
    if (expiresAt
        .isBefore(DateTime.now().subtract(const Duration(seconds: 2)))) {
      await supabase.auth.refreshSession();
    }
  }

}


