import 'package:explorify/config/env.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl => env.apiUrl;
  static String get wsUrl => env.wsUrl;

  static String get auth => '$baseUrl/auth';
  static String get tours => '$baseUrl/tours';
  static String get users => '$baseUrl/users';
  static String get chat => '$baseUrl/chat';
  static String get hotels => '$baseUrl/hotels';
  static String get search => '$baseUrl/search';
  static String get rentals => '$baseUrl/rentals';
  static String get upload => '$baseUrl/upload';
}
