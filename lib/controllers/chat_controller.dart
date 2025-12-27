import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../models/chat_models.dart';
import '../repository/chat_repository.dart';
import '../services/websocket_service.dart';
import 'auth_controller.dart';

/// Thin controller that delegates to ChatRepository
/// Handles navigation, app lifecycle, and exposes repository state to UI
class ChatController extends GetxController with WidgetsBindingObserver {
  late final ChatRepository _repository;
  final WebSocketService _webSocketService = WebSocketService.instance;

  @override
  void onInit() {
    super.onInit();
    // Register app lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Initialize repository
    _repository = Get.put(ChatRepository());

    // Set up WebSocket callbacks to route to repository
    _setupWebSocketCallbacks();

    // Initialize repository if user is logged in (defer to avoid setState during build)
    Future.microtask(() => _initializeIfLoggedIn());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // App came back to foreground - refresh data and reconnect if needed
      _onAppResumed();
    }
  }

  void _onAppResumed() {
    try {
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn) return;

      // Reconnect WebSocket if disconnected
      if (!_webSocketService.isConnected) {
        debugPrint('ChatController: App resumed, reconnecting WebSocket...');
        _repository.initialize();
      }

      // Always refresh chat list to get latest messages and unread counts
      _repository.loadUserChats();
    } catch (e) {
      debugPrint('ChatController: Error on app resume: $e');
    }
  }

  void _setupWebSocketCallbacks() {
    _webSocketService.onMessageReceived = (message, localId) {
      _repository.handleIncomingMessage(message, localId: localId);
    };

    _webSocketService.onMessageError = (error, localId) {
      _repository.handleMessageError(error, localId: localId);
    };

    _webSocketService.onTypingIndicator = (userId, isTyping) {
      _repository.handleTypingIndicator(userId, isTyping);
    };

    _webSocketService.onConnectionStatusChanged = (isConnected) {
      // Connection status updates are handled internally
    };

    _webSocketService.onChatNotification = (data) {
      _handleChatNotification(data);
    };
  }

  void _handleChatNotification(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final chatId = data['chatId'] as String?;

    if (type == null || chatId == null) return;

    switch (type) {
      case 'new_message':
        // Update unread count
        final unreadCount = data['unreadCount'] as int?;
        if (unreadCount != null) {
          _repository.updateUnreadCount(chatId, unreadCount);
        }
        // Update last message preview
        final messageData = data['message'] as Map<String, dynamic>?;
        if (messageData != null) {
          _repository.updateChatPreview(chatId, messageData);
        }
        break;
    }
  }

  void _initializeIfLoggedIn() {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn) {
        _repository.initialize();
      }
    } catch (e) {
      debugPrint('ChatController: Error initializing: $e');
    }
  }

  @override
  void onClose() {
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    // Clear WebSocket callbacks
    _webSocketService.onMessageReceived = null;
    _webSocketService.onMessageError = null;
    _webSocketService.onTypingIndicator = null;
    _webSocketService.onConnectionStatusChanged = null;
    _webSocketService.onChatNotification = null;
    _repository.clear();
    super.onClose();
  }

  // ============ GETTERS (Proxy to Repository) ============

  List<Chat> get chats => _repository.chats;
  List<ChatMessage> get messages => _repository.messages;
  bool get isLoading => _repository.isLoadingChats || _repository.isLoadingMessages;
  bool get isSendingMessage => _repository.isSendingMessage;
  String get errorMessage => _repository.errorMessage;
  Map<String, bool> get typingUsers => _repository.typingUsers;
  String? get currentUserId => _repository.currentUserId;

  // Filtered chats
  List<Chat> get groupChats => _repository.groupChats;
  List<Chat> get privateChats => _repository.privateChats;

  // Reactive unread counts for tab badges
  int get groupChatsUnreadCount => _repository.groupChatsUnreadCount;
  int get privateChatsUnreadCount => _repository.privateChatsUnreadCount;
  RxMap<String, int> get unreadCountsMap => _repository.unreadCountsMap;

  // ============ CHAT MANAGEMENT ============

  /// Create or get private chat with another user
  Future<Chat?> createPrivateChat(String targetUserId) async {
    return await _repository.createPrivateChat(targetUserId);
  }

  /// Load all user chats
  Future<void> loadUserChats({String? chatType}) async {
    await _repository.loadUserChats(chatType: chatType);
  }

  /// Load group chats only
  Future<void> loadGroupChats() async {
    await _repository.loadUserChats(chatType: 'group');
  }

  /// Load private chats only
  Future<void> loadPrivateChats() async {
    await _repository.loadUserChats(chatType: 'private');
  }

  /// Get unread count for a chat (uses server-tracked count)
  int getUnreadCount(String chatId) {
    return _repository.getUnreadCount(chatId);
  }

  /// Reactive total unread count for UI binding
  RxInt get totalUnreadCountRx => _repository.totalUnreadCountRx;

  /// Get total unread count
  int get totalUnreadCount => _repository.totalUnreadCount;

  // ============ MESSAGE MANAGEMENT ============

  /// Load messages for a chat
  Future<void> loadMessages(String chatId, {int page = 1, int limit = 50}) async {
    await _repository.loadMessages(chatId, page: page, limit: limit);
  }

  /// Send a message
  Future<void> sendMessage({
    required String chatId,
    required String content,
    MessageType messageType = MessageType.TEXT,
    List<MessageAttachment>? attachments,
    String? replyTo,
  }) async {
    await _repository.sendMessage(
      chatId: chatId,
      content: content,
      messageType: messageType,
      attachments: attachments,
      replyTo: replyTo,
    );
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId) async {
    await _repository.markMessagesAsRead(chatId);
  }

  // ============ CHAT SESSION ============

  /// Set current chat and load messages
  void setCurrentChat(Chat chat) {
    if (chat.id != null) {
      _repository.enterChat(chat.id!);
    }
  }

  /// Clear current chat session
  void clearChat() {
    _repository.exitChat();
  }

  // ============ TYPING INDICATORS ============

  void setTyping(String userId, bool isTyping) {
    _repository.handleTypingIndicator(userId, isTyping);
  }

  void sendTypingIndicator(String chatId, bool isTyping) {
    _repository.sendTypingIndicator(chatId, isTyping);
  }

  // ============ UTILITIES ============

  /// Format time for display
  String formatMessageTime(DateTime dateTime) {
    return _repository.formatMessageTime(dateTime);
  }

  void clearError() {
    _repository.clearError();
  }

  /// Add message from WebSocket (for backward compatibility)
  void addMessage(ChatMessage message) {
    _repository.handleIncomingMessage(message);
  }

  /// Connect WebSocket manually
  void connectWebSocket() {
    _repository.connectWebSocket();
  }

  /// Disconnect WebSocket
  void disconnectWebSocket() {
    _repository.disconnectWebSocket();
  }

  /// Test API connection (for debugging)
  Future<void> testApiConnection() async {
    try {
      await _repository.loadUserChats();
      Get.snackbar('Success', 'API connection successful!');
    } catch (e) {
      debugPrint('API test failed: $e');
      Get.snackbar('Error', 'API test failed: $e');
    }
  }
}
