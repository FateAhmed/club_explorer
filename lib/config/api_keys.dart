/// Centralized API keys configuration
///
/// For production, consider using --dart-define for build-time injection:
/// flutter build --dart-define=GOOGLE_MAPS_API_KEY=your_key
class ApiKeys {
  /// Google Maps API key for directions and map services
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyBLTm_mUtLfjWxUZD5YB4_BNoYXz-AUw5U',
  );
}
