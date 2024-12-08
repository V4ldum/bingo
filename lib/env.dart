import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(useConstantCase: true)
abstract class Env {
  @EnviedField()
  static const String url = _Env.url;
  @EnviedField(obfuscate: true)
  static final String key = _Env.key;
}
