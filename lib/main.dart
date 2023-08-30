import 'dart:async';
import 'dart:isolate';

import 'package:bufalabuona/app_config.dart';
import 'package:bufalabuona/app_launcher.dart';
import 'package:bufalabuona/env/app_env.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          apiKey: AppEnv().firebaseApiKey,
          authDomain: AppEnv().firebaseAuthDomain,
          projectId: AppEnv().firebaseProjectId,
          storageBucket: AppEnv().firebaseStorageBucket,
          messagingSenderId: AppEnv().firebaseMessagingSenderId,
          appId: AppEnv().firebaseAppId,
          measurementId: AppEnv().firebaseMesurementId
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

  await Supabase.initialize(
      url: AppEnv().supabaseUrl,
      anonKey: AppEnv().supabaseAnonKey,
      authCallbackUrlHostname:AppEnv().myAuthRedirectUri
  );  /// Initialize Crash report

  await SupabaseAuth.initialize(authCallbackUrlHostname: AppEnv().myAuthRedirectUri, authFlowType: AuthFlowType.pkce);

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

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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


