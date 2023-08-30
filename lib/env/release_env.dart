import 'package:envied/envied.dart';

import 'app_env.dart';
import 'app_env_fields.dart';

part 'release_env.g.dart';

@Envied(name: 'Env', path: '.env.release')
class ReleaseEnv implements AppEnv, AppEnvFields {
  const ReleaseEnv();

  @override
  @EnviedField(varName: 'SUPABASE_URL')
  final String supabaseUrl = _Env.supabaseUrl;
  @override
  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  final String supabaseAnonKey = _Env.supabaseAnonKey;
  @override
  @EnviedField(varName: 'MY_AUTH_REDIRECT_URI')
  final String myAuthRedirectUri = _Env.myAuthRedirectUri;

  @override
  @EnviedField(varName: 'FIREBASE_API_KEY')
  final String firebaseApiKey = _Env.firebaseApiKey;

  @override
  @EnviedField(varName: 'FIREBASE_AUTH_DOMAIN')
  final String firebaseAuthDomain = _Env.firebaseAuthDomain;

  @override
  @EnviedField(varName: 'FIREBASE_PROJECT_ID')
  final String firebaseProjectId = _Env.firebaseProjectId;

  @override
  @EnviedField(varName: 'FIREBASE_STORAGE_BUCKET')
  final String firebaseStorageBucket = _Env.firebaseStorageBucket;

  @override
  @EnviedField(varName: 'FIREBASE_MESSAGING_SENDER_ID')
  final String firebaseMessagingSenderId = _Env.firebaseMessagingSenderId;

  @override
  @EnviedField(varName: 'FIREBASE_APP_ID')
  final String firebaseAppId = _Env.firebaseAppId;

  @override
  @EnviedField(varName: 'FIREBASE_MESUREMENT_ID')
  final String firebaseMesurementId = _Env.firebaseMesurementId;

}