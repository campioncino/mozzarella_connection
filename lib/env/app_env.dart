
import 'app_env_fields.dart';
import 'release_env.dart';

abstract class AppEnv implements AppEnvFields {
  factory AppEnv() => _instance;
  static  AppEnv _instance =  ReleaseEnv();
}