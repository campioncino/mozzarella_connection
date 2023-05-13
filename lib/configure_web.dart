// import 'package:supabase_flutter/supabase_flutter.dart';
//
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// Future configureApp() async {
//   await dotenv.load(fileName: "assets/.env");
//   // init Supabase singleton
//   // no localStorage provided, fallback to use hive as default
//   await Supabase.initialize(
//     url: dotenv.env['SUPABASE_URL'],
//     anonKey: dotenv.env['SUPABASE_ANON_KEY'],
//     authCallbackUrlHostname: dotenv.env['MY_AUTH_REDIRECT_URI'],
//     debug: true,
//   );
// }