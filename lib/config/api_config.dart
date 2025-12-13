class ApiConfig {
  // Base URLs
  static const String baseUrl = 'https://club-explorer.ahmadt.com';
  static const String apiBaseUrl = '$baseUrl/api';
  static const String websocketUrl = 'ws://club-explorer.ahmadt.com';

  // API Endpoints
  static const String chatBaseUrl = '$apiBaseUrl/chat';
  static const String authBaseUrl = '$apiBaseUrl/auth';
  static const String tourBaseUrl = '$apiBaseUrl/tours';
  static const String userBaseUrl = '$apiBaseUrl/users';
  static const String hotelBaseUrl = '$apiBaseUrl/hotels';
  static const String searchBaseUrl = '$apiBaseUrl/search';
  static const String rentalBaseUrl = '$apiBaseUrl/rentals';
  static const String uploadBaseUrl = '$apiBaseUrl/upload';

  // Chat specific endpoints
  static const String getUserChats = '$chatBaseUrl/user';
  static const String getChatByTourId = '$chatBaseUrl/tour';
  static const String sendMessage = '$chatBaseUrl';
  static const String getChatMessages = '$chatBaseUrl';
  static const String updateMessage = '$chatBaseUrl';
  static const String deleteMessage = '$chatBaseUrl';
  static const String markMessagesAsRead = '$chatBaseUrl';

  // Environment configuration
  static const bool isProduction = true; // Set to true for production

  // Production URLs (uncomment and modify for production)
  static const String productionBaseUrl = 'https://club-explorer.ahmadt.com';
  static const String productionWebsocketUrl = 'wss://club-explorer.ahmadt.com';

  // Get current base URL based on environment
  static String get currentBaseUrl => isProduction ? productionBaseUrl : baseUrl;
  static String get currentApiBaseUrl => isProduction ? '$productionBaseUrl/api' : apiBaseUrl;
  static String get currentWebsocketUrl =>
      isProduction ? productionWebsocketUrl : websocketUrl; // Socket.IO uses WebSocket protocol

  // Get current chat base URL
  static String get currentChatBaseUrl => '$currentApiBaseUrl/chat';

  // Helper method to build full URL
  static String buildUrl(String endpoint) {
    return '$currentApiBaseUrl$endpoint';
  }

  // Helper method to build chat URL
  static String buildChatUrl(String endpoint) {
    return '$currentChatBaseUrl$endpoint';
  }
}
