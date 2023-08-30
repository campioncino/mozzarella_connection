import 'package:envied/envied.dart';

/// Both DebugEnv and ReleaseEnv must implement all these values
@EnviedField(obfuscate: true)
abstract class AppEnvFields {
  abstract final String supabaseUrl;
  abstract final String supabaseAnonKey;
  abstract final String myAuthRedirectUri;

  abstract final String firebaseApiKey;
  abstract final String firebaseAuthDomain;
  abstract final String firebaseProjectId;
  abstract final String firebaseStorageBucket;
  abstract final String firebaseMessagingSenderId;
  abstract final String firebaseAppId;
  abstract final String firebaseMesurementId;

}
