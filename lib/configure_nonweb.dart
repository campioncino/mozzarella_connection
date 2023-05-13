// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
//
// Future configureApp() async {
//    await dotenv.load(fileName: "assets/.env");
//   // init Supabase singleton
//   await Supabase.initialize(
//     url: dotenv.env['SUPABASE_URL'],
//     anonKey: dotenv.env['SUPABASE_ANON_KEY'],
//     authCallbackUrlHostname: dotenv.env['MY_AUTH_REDIRECT_URI']??'',
//     debug: true,
//     localStorage: SecureLocalStorage(),
//   );
//    await dotenv.load(fileName: "assets/.env");
//
//    await Supabase.initialize(url:  dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);
// }
//
// // user flutter_secure_storage to persist user session
// class SecureLocalStorage extends LocalStorage {
//   SecureLocalStorage()
//       : super(
//     initialize: () async {},
//     hasAccessToken: () {
//       const storage = FlutterSecureStorage();
//       return storage.containsKey(key: supabasePersistSessionKey);
//     },
//     accessToken: () {
//       const storage = FlutterSecureStorage();
//       return storage.read(key: supabasePersistSessionKey);
//     },
//     removePersistedSession: () {
//       const storage = FlutterSecureStorage();
//       return storage.delete(key: supabasePersistSessionKey);
//     },
//     persistSession: (String value) {
//       const storage = FlutterSecureStorage();
//       return storage.write(key: supabasePersistSessionKey, value: value);
//     },
//   );
// }