import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(useConstantCase: true, obfuscate: true)
abstract class Env {
  @EnviedField()
  static final String url = _Env.url;

  @EnviedField()
  static final String key = _Env.key;
}
