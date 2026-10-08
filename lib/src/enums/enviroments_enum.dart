enum EnvironmentEnum {
  constants(
    apiBaseUrl: 'https://api.hgbrasil.com/weather',
    apiKey: String.fromEnvironment('API_KEY'),
    imageUrl: 'https://assets.hgbrasil.com/weather/icons/conditions/',
    moonPhaseUrl: 'https://assets.hgbrasil.com/weather/icons/moon/',
  );

  final String apiBaseUrl;
  final String apiKey;
  final String imageUrl;
  final String moonPhaseUrl;

  const EnvironmentEnum({
    required this.apiBaseUrl,
    required this.apiKey,
    required this.imageUrl,
    required this.moonPhaseUrl,
  });

  // Getters de compatibilidade
  String get API_BASE_URL => apiBaseUrl;
  String get API_KEY => apiKey;
  String get IMAGE_URL => imageUrl;
  String get MOON_PHASE_URL => moonPhaseUrl;
}
