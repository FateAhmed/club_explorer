import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthController extends GetxController {
  // Observable state
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> user = <String, dynamic>{}.obs;
  final RxString accessToken = ''.obs;
  final RxString refreshToken = ''.obs;

  // SharedPreferences keys
  static const String _userDataKey = 'user_data';
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _profileImageKey = 'profile_image';

  // Profile image path (stored locally)
  final RxString profileImage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  /// Initialize auth state from stored data
  Future<void> _initializeAuth() async {
    try {
      await loadUserData();

      // If we have tokens, validate them
      if (accessToken.value.isNotEmpty) {
        final isValid = await _validateToken();
        if (!isValid) {
          // Try to refresh the token
          final refreshed = await refreshAccessToken();
          if (!refreshed) {
            // Token invalid and refresh failed, clear auth state
            await _clearAuthData();
          }
        }
      }
    } catch (e) {
      print('Auth initialization error: $e');
    } finally {
      isInitialized.value = true;
    }
  }

  /// Validate the current access token by making a profile request
  Future<bool> _validateToken() async {
    if (accessToken.value.isEmpty) return false;

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.userBaseUrl}/profile'),
        headers: _authHeaders,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          // Update user data with fresh data from server
          user.assignAll(data['data']);
          await _saveUserData();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  /// Get auth headers for API requests
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (accessToken.value.isNotEmpty) 'Authorization': 'Bearer ${accessToken.value}',
  };

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.authBaseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _handleAuthSuccess(data['data']);
        return true;
      } else {
        _handleAuthError(data);
        return false;
      }
    } catch (e) {
      _handleNetworkError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Register a new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final body = {
        'email': email.trim().toLowerCase(),
        'password': password,
        'name': name.trim(),
      };

      if (phone != null && phone.isNotEmpty) body['phone'] = phone.trim();
      if (address != null && address.isNotEmpty) body['address'] = address.trim();

      final response = await http.post(
        Uri.parse('${ApiConfig.authBaseUrl}/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _handleAuthSuccess(data['data']);
        return true;
      } else {
        _handleAuthError(data);
        return false;
      }
    } catch (e) {
      _handleNetworkError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Google OAuth authentication
  Future<bool> googleAuth(String token) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.authBaseUrl}/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await _handleAuthSuccess(data['data']);
        return true;
      } else {
        _handleAuthError(data);
        return false;
      }
    } catch (e) {
      _handleNetworkError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    if (refreshToken.value.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.authBaseUrl}/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken.value}),
      ).timeout(const Duration(seconds: 15));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        accessToken.value = data['data']['accessToken'];
        refreshToken.value = data['data']['refreshToken'];
        await _saveUserData();
        return true;
      }
      return false;
    } catch (e) {
      print('Token refresh error: $e');
      return false;
    }
  }

  /// Request password reset email
  Future<bool> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.authBaseUrl}/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim().toLowerCase()}),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else {
        _handleAuthError(data);
        return false;
      }
    } catch (e) {
      _handleNetworkError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update password with reset token
  Future<bool> updatePassword(String token, String newPassword) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.post(
        Uri.parse('${ApiConfig.authBaseUrl}/update-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else {
        _handleAuthError(data);
        return false;
      }
    } catch (e) {
      _handleNetworkError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final body = <String, dynamic>{};
      if (name != null && name.isNotEmpty) body['name'] = name.trim();
      if (phone != null) body['phone'] = phone.trim();
      if (address != null) body['address'] = address.trim();

      final response = await http.put(
        Uri.parse('${ApiConfig.userBaseUrl}/profile'),
        headers: _authHeaders,
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        user.assignAll(data['data']);
        await _saveUserData();
        return true;
      } else {
        _handleAuthError(data);
        return false;
      }
    } catch (e) {
      _handleNetworkError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Change user password (when logged in)
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await http.put(
        Uri.parse('${ApiConfig.userBaseUrl}/password'),
        headers: _authHeaders,
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      } else {
        _handleAuthError(data);
        return false;
      }
    } catch (e) {
      _handleNetworkError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout and clear all auth data
  Future<void> logout() async {
    await _clearAuthData();
  }

  /// Handle successful authentication
  Future<void> _handleAuthSuccess(Map<String, dynamic> data) async {
    user.assignAll(data['user']);
    accessToken.value = data['accessToken'];
    refreshToken.value = data['refreshToken'];
    await _saveUserData();
  }

  /// Handle authentication errors
  void _handleAuthError(Map<String, dynamic> data) {
    // Check for validation errors array
    if (data['errors'] != null && data['errors'] is List && (data['errors'] as List).isNotEmpty) {
      errorMessage.value = (data['errors'] as List).join('\n');
    } else {
      errorMessage.value = data['message'] ?? 'An error occurred';
    }
  }

  /// Handle network errors
  void _handleNetworkError(dynamic e) {
    if (e.toString().contains('TimeoutException')) {
      errorMessage.value = 'Connection timed out. Please check your internet connection.';
    } else if (e.toString().contains('SocketException')) {
      errorMessage.value = 'No internet connection. Please check your network.';
    } else {
      errorMessage.value = 'Network error. Please try again.';
    }
    print('Network error: $e');
  }

  /// Clear all authentication data
  Future<void> _clearAuthData() async {
    user.clear();
    accessToken.value = '';
    refreshToken.value = '';
    profileImage.value = '';
    errorMessage.value = '';

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_profileImageKey);
  }

  /// Load user data from SharedPreferences
  Future<void> loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);
      final accessTokenString = prefs.getString(_accessTokenKey);
      final refreshTokenString = prefs.getString(_refreshTokenKey);
      final profileImageString = prefs.getString(_profileImageKey);

      if (userDataString != null &&
          accessTokenString != null &&
          refreshTokenString != null &&
          accessTokenString.isNotEmpty) {
        user.assignAll(jsonDecode(userDataString));
        accessToken.value = accessTokenString;
        refreshToken.value = refreshTokenString;
      }

      if (profileImageString != null) {
        profileImage.value = profileImageString;
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  /// Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userDataKey, jsonEncode(user));
      await prefs.setString(_accessTokenKey, accessToken.value);
      await prefs.setString(_refreshTokenKey, refreshToken.value);
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  /// Make authenticated API request with automatic token refresh
  Future<http.Response> authenticatedRequest({
    required String method,
    required String url,
    Map<String, dynamic>? body,
  }) async {
    var response = await _makeRequest(method, url, body);

    // If unauthorized, try to refresh token and retry
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await refreshAccessToken();
      if (refreshed) {
        response = await _makeRequest(method, url, body);
      } else {
        // Refresh failed, logout user
        await logout();
      }
    }

    return response;
  }

  Future<http.Response> _makeRequest(String method, String url, Map<String, dynamic>? body) async {
    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(Uri.parse(url), headers: _authHeaders);
      case 'POST':
        return await http.post(Uri.parse(url), headers: _authHeaders, body: body != null ? jsonEncode(body) : null);
      case 'PUT':
        return await http.put(Uri.parse(url), headers: _authHeaders, body: body != null ? jsonEncode(body) : null);
      case 'DELETE':
        return await http.delete(Uri.parse(url), headers: _authHeaders);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }

  // Getters
  bool get isLoggedIn => accessToken.value.isNotEmpty;
  Map<String, dynamic> get userData => Map<String, dynamic>.from(user);
  String get token => accessToken.value;
  String get userId => user['_id']?.toString() ?? user['id']?.toString() ?? '';
  String get userName => user['name']?.toString() ?? '';
  String get userEmail => user['email']?.toString() ?? '';
  bool get isEmailVerified => user['isEmailVerified'] == true;
  String get userProfileImage => profileImage.value;

  /// Clear error message
  void clearError() {
    errorMessage.value = '';
  }

  /// Update profile image path (stored locally)
  Future<void> updateProfileImage(String imagePath) async {
    profileImage.value = imagePath;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, imagePath);
  }
}
