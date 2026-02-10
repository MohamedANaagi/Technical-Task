/// Application environment configuration per flavor (dev / prod).
abstract final class AppEnv {
  AppEnv._();

  static AppEnvConfig _config = AppEnvConfig.prod;

  static AppEnvConfig get current => _config;

  static void init(Flavor flavor) {
    _config = switch (flavor) {
      Flavor.dev => AppEnvConfig.dev,
      Flavor.prod => AppEnvConfig.prod,
    };
  }
}

enum Flavor { dev, prod }

class AppEnvConfig {
  const AppEnvConfig({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
    this.showDebugBanner = true,
  });

  final Flavor flavor;
  final String baseUrl;
  final String appName;
  final bool showDebugBanner;

  static const dev = AppEnvConfig(
    flavor: Flavor.dev,
    baseUrl: 'https://fakestoreapi.com',
    appName: 'Technica Dev',
    showDebugBanner: true,
  );

  static const prod = AppEnvConfig(
    flavor: Flavor.prod,
    baseUrl: 'https://fakestoreapi.com',
    appName: 'Technica Task',
    showDebugBanner: false,
  );

  bool get isDev => flavor == Flavor.dev;
  bool get isProd => flavor == Flavor.prod;
}
