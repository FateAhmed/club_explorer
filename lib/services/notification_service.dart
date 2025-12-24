import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../controllers/auth_controller.dart';
import '../config/api_config.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message received: ${message.messageId}');
  // Background messages are handled by FCM automatically (shows notification)
}

/// Singleton service for handling push notifications
class NotificationService extends GetxService {
  static NotificationService get instance => Get.find<NotificationService>();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Storage keys
  static const String _fcmTokenKey = 'fcm_token';
  static const String _fcmTokenSentKey = 'fcm_token_sent';
  static const String _deviceIdKey = 'device_id';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationPromptShownKey = 'notification_prompt_shown';

  // Observable state for UI
  final RxBool isNotificationsEnabled = false.obs;
  final RxBool isPermissionGranted = false.obs;
  final RxBool isLoading = false.obs;

  // Current viewing chat ID (to suppress notifications)
  String? _currentViewingChatId;

  // Android notification channel
  static const AndroidNotificationChannel _chatChannel =
      AndroidNotificationChannel(
    'chat_messages',
    'Chat Messages',
    description: 'Notifications for new chat messages',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize the notification service
  Future<NotificationService> init() async {
    // Set up background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Initialize local notifications
    await _initLocalNotifications();

    // Load saved notification preference and check current permission status
    await _loadNotificationPreference();
    await _checkPermissionStatus();

    // Set up foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Set up notification tap handlers
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from terminated state via notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      // Delay to ensure app is ready
      Future.delayed(const Duration(seconds: 1), () {
        _handleNotificationTap(initialMessage);
      });
    }

    // If notifications were previously enabled and permission is granted, set up token
    if (isNotificationsEnabled.value && isPermissionGranted.value) {
      await _setupTokenRefreshListener();
    }

    return this;
  }

  /// Load saved notification preference from storage
  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    isNotificationsEnabled.value = prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  /// Check current permission status without requesting
  Future<void> _checkPermissionStatus() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    isPermissionGranted.value =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  /// Initialize local notifications plugin
  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // Create Android notification channel
    final androidPlugin =
        _localNotifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_chatChannel);
  }

  /// Request notification permissions (called when user enables notifications)
  Future<bool> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
    );

    print('Notification permission status: ${settings.authorizationStatus}');

    // For Android 13+, also request local notification permission
    if (Platform.isAndroid) {
      final granted = await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      isPermissionGranted.value = granted ?? false;
    } else {
      isPermissionGranted.value =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }

    return isPermissionGranted.value;
  }

  /// Set up token refresh listener
  Future<void> _setupTokenRefreshListener() async {
    try {
      // On iOS, check if APNs token is available (simulators don't support push)
      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          print('APNs token not available (simulator or push not configured)');
          // On simulators, we can't get FCM token, but still listen for refresh
          _firebaseMessaging.onTokenRefresh.listen(_onTokenReceived);
          return;
        }
      }

      // Get initial token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _onTokenReceived(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen(_onTokenReceived);
    } catch (e) {
      print('Error setting up FCM token: $e');
      // Still listen for token refresh in case token becomes available later
      _firebaseMessaging.onTokenRefresh.listen(_onTokenReceived);
    }
  }

  /// Handle new/refreshed FCM token
  Future<void> _onTokenReceived(String token) async {
    print('FCM Token received: ${token.substring(0, 20)}...');

    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_fcmTokenKey);

    // Only send to server if token changed or not yet sent
    if (savedToken != token || prefs.getBool(_fcmTokenSentKey) != true) {
      await prefs.setString(_fcmTokenKey, token);
      await _sendTokenToServer(token);
    }
  }

  /// Send FCM token to server
  Future<void> _sendTokenToServer(String token) async {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn) {
        print('Not logged in, skipping FCM token registration');
        return;
      }

      final deviceId = await _getDeviceId();

      final response = await http.post(
        Uri.parse('${ApiConfig.users}/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${authController.token}',
        },
        body: jsonEncode({
          'fcmToken': token,
          'platform': Platform.isIOS ? 'ios' : 'android',
          'deviceId': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_fcmTokenSentKey, true);
        print('FCM token registered successfully');
      } else {
        print('Failed to register FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  /// Get unique device identifier
  Future<String> _getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey);
    if (deviceId == null) {
      deviceId = DateTime.now().millisecondsSinceEpoch.toString();
      await prefs.setString(_deviceIdKey, deviceId);
    }
    return deviceId;
  }

  /// Handle foreground messages - show local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.data}');

    final data = message.data;
    final chatId = data['chatId'];
    final senderId = data['senderId'];

    // Don't show notification if viewing this chat
    if (_currentViewingChatId != null && _currentViewingChatId == chatId) {
      print('Suppressing notification - user viewing this chat');
      return;
    }

    // Don't show notification for own messages
    try {
      final authController = Get.find<AuthController>();
      if (senderId == authController.userId) {
        print('Suppressing notification - own message');
        return;
      }
    } catch (e) {
      // AuthController not found, continue with notification
    }

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final data = message.data;

    final title = notification?.title ?? data['senderName'] ?? 'New Message';
    final body = notification?.body ?? _formatNotificationBody(data);

    final androidDetails = AndroidNotificationDetails(
      _chatChannel.id,
      _chatChannel.name,
      channelDescription: _chatChannel.description,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'New message',
      icon: '@mipmap/launcher_icon',
      color: const Color(0xFFD6B45D),
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use chatId hash as notification ID for grouping
    final notificationId =
        data['chatId']?.hashCode ?? DateTime.now().millisecondsSinceEpoch;

    await _localNotifications.show(
      notificationId,
      title,
      body,
      details,
      payload: jsonEncode(data),
    );
  }

  /// Format notification body based on message type
  String _formatNotificationBody(Map<String, dynamic> data) {
    final messageType = data['messageType'] ?? 'text';
    final content = data['content'] ?? '';

    switch (messageType) {
      case 'image':
        return 'Sent an image';
      case 'file':
        return 'Sent a file';
      case 'location':
        return 'Shared a location';
      case 'text':
      default:
        return content.length > 100
            ? '${content.substring(0, 100)}...'
            : content;
    }
  }

  /// Handle notification tap (app in background)
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.data}');
    _navigateToChat(message.data);
  }

  /// Handle local notification tap
  void _onLocalNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateToChat(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  /// Navigate to specific chat
  void _navigateToChat(Map<String, dynamic> data) {
    final chatId = data['chatId'];
    final chatName = data['chatName'] ?? data['senderName'] ?? 'Chat';

    if (chatId == null) {
      print('Cannot navigate - no chatId in notification data');
      return;
    }

    // Defer navigation until app is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _performChatNavigation(chatId, chatName);
    });
  }

  /// Perform the actual navigation to chat
  void _performChatNavigation(String chatId, String chatName) {
    // Navigate to chat screen using GetX
    // We use Get.toNamed with arguments for the chat screen
    Get.toNamed(
      '/chat',
      arguments: {
        'chatId': chatId,
        'chatName': chatName,
      },
    );
  }

  // ============ PUBLIC API ============

  /// Call when entering a chat to suppress notifications
  void setCurrentViewingChat(String? chatId) {
    _currentViewingChatId = chatId;
    print('Current viewing chat set to: $chatId');
  }

  /// Call on logout to clear token
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_fcmTokenKey);
      final deviceId = await _getDeviceId();

      if (token != null) {
        // Notify server to remove this token
        try {
          final authController = Get.find<AuthController>();
          if (authController.isLoggedIn) {
            await http.delete(
              Uri.parse('${ApiConfig.users}/fcm-token'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${authController.token}',
              },
              body: jsonEncode({
                'fcmToken': token,
                'deviceId': deviceId,
              }),
            );
          }
        } catch (e) {
          print('Error notifying server of token removal: $e');
        }
      }

      await prefs.remove(_fcmTokenKey);
      await prefs.remove(_fcmTokenSentKey);
      await _firebaseMessaging.deleteToken();

      print('FCM token cleared');
    } catch (e) {
      print('Error clearing FCM token: $e');
    }
  }

  /// Re-register token (call on login)
  Future<void> registerToken() async {
    // Only register if notifications are enabled
    if (!isNotificationsEnabled.value) {
      print('Notifications disabled, skipping token registration');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_fcmTokenSentKey, false);

      // On iOS, check if APNs token is available first
      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          print('APNs not available, skipping token registration');
          return;
        }
      }

      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _onTokenReceived(token);
      }
    } catch (e) {
      print('Error registering FCM token: $e');
    }
  }

  /// Enable notifications - requests permission if needed and registers token
  Future<bool> enableNotifications() async {
    isLoading.value = true;

    try {
      // Check current permission status
      await _checkPermissionStatus();

      // Request permission if not already granted
      if (!isPermissionGranted.value) {
        final granted = await _requestPermissions();
        if (!granted) {
          isLoading.value = false;
          return false;
        }
      }

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, true);
      isNotificationsEnabled.value = true;

      // Register FCM token
      await _setupTokenRefreshListener();

      print('Notifications enabled successfully');
      isLoading.value = false;
      return true;
    } catch (e) {
      print('Error enabling notifications: $e');
      isLoading.value = false;
      return false;
    }
  }

  /// Disable notifications - clears token from server
  Future<void> disableNotifications() async {
    isLoading.value = true;

    try {
      // Clear token from server
      await clearToken();

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, false);
      isNotificationsEnabled.value = false;

      print('Notifications disabled');
    } catch (e) {
      print('Error disabling notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Toggle notifications on/off
  Future<bool> toggleNotifications() async {
    if (isNotificationsEnabled.value) {
      await disableNotifications();
      return false;
    } else {
      return await enableNotifications();
    }
  }

  /// Check if notifications can be enabled (permission not permanently denied)
  Future<bool> canRequestPermission() async {
    final settings = await _firebaseMessaging.getNotificationSettings();
    // On iOS, if denied, user must go to settings
    // On Android 13+, can re-request if not permanently denied
    return settings.authorizationStatus != AuthorizationStatus.denied;
  }

  /// Open app notification settings (for when permission is denied)
  Future<void> openNotificationSettings() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    // For iOS, user needs to go to Settings app manually
    // We can show a dialog directing them there
  }

  /// Check if first-time notification prompt should be shown
  Future<bool> shouldShowFirstTimePrompt() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShown = prefs.getBool(_notificationPromptShownKey) ?? false;
    return !hasShown && !isNotificationsEnabled.value;
  }

  /// Mark that the first-time prompt has been shown
  Future<void> markPromptAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationPromptShownKey, true);
  }
}
