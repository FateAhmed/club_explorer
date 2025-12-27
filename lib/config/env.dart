import 'dart:io' show Platform;

enum Environment { development, staging, production }

class Env {
  static final Env _instance = Env._internal();
  factory Env() => _instance;
  Env._internal();

  Environment _environment = Environment.development;

  // Localhost for emulators: Android uses 10.0.2.2, iOS uses localhost
  static String get _localhost => Platform.isAndroid ? '10.0.2.2' : 'localhost';

  // URLs per environment
  static Map<Environment, Map<String, String>> get _config => {
    Environment.development: {
      'apiUrl': 'http://$_localhost:7043',
      'wsUrl': 'ws://$_localhost:7043',
      'webUrl': 'http://$_localhost:3000',
    },
    Environment.staging: {
      'apiUrl': 'https://club-explorer.ahmadt.com',
      'wsUrl': 'wss://club-explorer.ahmadt.com',
      'webUrl': 'https://explorifymotorcycle.com',
    },
    Environment.production: {
      'apiUrl': 'https://club-explorer.ahmadt.com',
      'wsUrl': 'wss://club-explorer.ahmadt.com',
      'webUrl': 'https://explorifymotorcycle.com',
    },
  };

  // Initialize environment
  void init(Environment env) {
    _environment = env;
  }

  // Getters
  Environment get environment => _environment;
  bool get isDevelopment => _environment == Environment.development;
  bool get isStaging => _environment == Environment.staging;
  bool get isProduction => _environment == Environment.production;

  String get baseUrl => _config[_environment]!['apiUrl']!;
  String get wsUrl => _config[_environment]!['wsUrl']!;
  String get webUrl => _config[_environment]!['webUrl']!;
  String get apiUrl => '$baseUrl/api';
}

// Global instance
final env = Env();
