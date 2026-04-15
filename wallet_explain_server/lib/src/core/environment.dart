import 'package:dotenv/dotenv.dart' as dotenv;

class Environment {
  Environment._(this._env);

  final dotenv.DotEnv _env;

  static Environment load() {
    final env = dotenv.DotEnv()..load();
    return Environment._(env);
  }

  String? get(String key) => _env[key];

  String require(String key) {
    final value = _env[key];
    if (value == null || value.isEmpty) {
      throw StateError('Missing environment variable: $key');
    }
    return value;
  }
}
