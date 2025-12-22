import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../controllers/auth_controller.dart';
import '../config/api_config.dart';

/// Connection status for WebSocket
enum ChatConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
}

/// Single source of truth for all chat data
/// Handles message deduplication, optimistic updates, and coordinates WebSocket/API calls
class ChatRepository extends GetxService {
  final ChatService _chatService = ChatService();
  late final WebSocketService _webSocketService;

  // Observable state
  final RxList<Chat> _chats = <Chat>[].obs;
  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  final Rx<ChatConnectionStatus> _connectionStatus = ChatConnectionStatus.disconnected.obs;
  final RxBool _isLoadingChats = false.obs;
  final RxBool _isLoadingMessages = false.obs;
  final RxBool _isSendingMessage = false.obs;
  final RxString _errorMessage = ''.obs;

  // Deduplication sets
  final Set<String> _messageIds = {};
  final Map<String, String> _localIdToServerId = {};

  // Caches (reactive for UI updates)
  final RxMap<String, int> _unreadCounts = <String, int>{}.obs;
  final RxInt _totalUnreadCount = 0.obs;
  String? _currentUserId;
  String? _currentChatId;

  // Getters
  List<Chat> get chats => _chats;
  List<ChatMessage> get messages => _messages;
  ChatConnectionStatus get connectionStatus => _connectionStatus.value;
  bool get isLoadingChats => _isLoadingChats.value;
  bool get isLoadingMessages => _isLoadingMessages.value;
  bool get isSendingMessage => _isSendingMessage.value;
  String get errorMessage => _errorMessage.value;
  String? get currentUserId => _currentUserId;
  String? get currentChatId => _currentChatId;

  // Filtered chat getters
  List<Chat> get groupChats => _chats.where((c) => c.isGroupChat).toList();
  List<Chat> get privateChats => _chats.where((c) => c.isPrivateChat).toList();

  // Reactive unread counts for tabs
  RxMap<String, int> get unreadCountsMap => _unreadCounts;

  int get groupChatsUnreadCount {
    int count = 0;
    for (final chat in groupChats) {
      if (chat.id != null) {
        count += _unreadCounts[chat.id!] ?? 0;
      }
    }
    return count;
  }

  int get privateChatsUnreadCount {
    int count = 0;
    for (final chat in privateChats) {
      if (chat.id != null) {
        count += _unreadCounts[chat.id!] ?? 0;
      }
    }
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    _webSocketService = WebSocketService.instance;
    _initializeFromAuth();

    // Listen to unread counts changes and update total
    ever(_unreadCounts, (_) => _updateTotalUnreadCount());
  }

  /// Update total unread count from map
  void _updateTotalUnreadCount() {
    _totalUnreadCount.value = _unreadCounts.values.fold(0, (sum, count) => sum + count);
  }

  /// Update a chat's lastMessage and lastActivity when new message arrives
  void _updateChatWithNewMessage(ChatMessage message) {
    final chatIndex = _chats.indexWhere((c) => c.id == message.chatId);
    if (chatIndex == -1) return;

    final chat = _chats[chatIndex];
    final updatedChat = chat.copyWith(
      lastMessage: message,
      lastActivity: message.createdAt,
    );

    // Remove from current position and insert at top (most recent)
    _chats.removeAt(chatIndex);
    _chats.insert(0, updatedChat);

    // Force notify listeners to ensure UI updates
    _chats.refresh();
  }

  /// Initialize repository with auth data
  void _initializeFromAuth() {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn) {
        _currentUserId = authController.userId;
        _chatService.setAuthToken(authController.token);
      }
    } catch (e) {
      print('ChatRepository: Error initializing from auth: $e');
    }
  }

  /// Initialize the repository (call after login)
  Future<void> initialize() async {
    _initializeFromAuth();
    if (_currentUserId != null && _currentUserId!.isNotEmpty) {
      await loadUserChats();
      connectWebSocket();
    }
  }

  /// Connect to WebSocket with proper user ID
  void connectWebSocket() {
    if (_currentUserId == null || _currentUserId!.isEmpty) {
      print('ChatRepository: Cannot connect WebSocket - no user ID');
      return;
    }

    _connectionStatus.value = ChatConnectionStatus.connecting;
    _webSocketService.connect(ApiConfig.wsUrl, _currentUserId!);

    // Set connection status based on WebSocket state
    if (_webSocketService.isConnected) {
      _connectionStatus.value = ChatConnectionStatus.connected;

      // Rejoin current chat if any
      if (_currentChatId != null) {
        _webSocketService.joinChat(_currentChatId!);
      }
    }
  }

  /// Disconnect WebSocket
  void disconnectWebSocket() {
    _webSocketService.disconnect();
    _connectionStatus.value = ChatConnectionStatus.disconnected;
  }

  // ============ CHAT OPERATIONS ============

  /// Load all user chats
  Future<void> loadUserChats({String? chatType}) async {
    try {
      _isLoadingChats.value = true;
      _errorMessage.value = '';

      final chats = await _chatService.getUserChats(chatType: chatType);
      _chats.assignAll(chats);

      // Update unread counts from participants data
      _updateUnreadCountsFromChats(chats);
    } catch (e) {
      _errorMessage.value = e.toString();
      print('ChatRepository: Error loading chats: $e');
    } finally {
      _isLoadingChats.value = false;
    }
  }

  /// Update cached unread counts from chat participants
  void _updateUnreadCountsFromChats(List<Chat> chats) {
    if (_currentUserId == null) return;

    for (final chat in chats) {
      final participant = chat.participants.firstWhereOrNull(
        (p) => p.userId == _currentUserId,
      );
      if (participant != null && chat.id != null) {
        _unreadCounts[chat.id!] = participant.unreadCount;
      }
    }
    // Trigger reactive update
    _updateTotalUnreadCount();
  }

  /// Get unread count for a specific chat (uses server-tracked count)
  int getUnreadCount(String chatId) {
    return _unreadCounts[chatId] ?? 0;
  }

  /// Reactive total unread count for UI binding
  RxInt get totalUnreadCountRx => _totalUnreadCount;

  /// Get total unread count across all chats
  int get totalUnreadCount => _totalUnreadCount.value;

  /// Create or get private chat with another user
  Future<Chat?> createPrivateChat(String targetUserId) async {
    try {
      _isLoadingChats.value = true;
      _errorMessage.value = '';

      final chat = await _chatService.createPrivateChat(targetUserId);

      // Add to chats list if not already there
      final existingIndex = _chats.indexWhere((c) => c.id == chat.id);
      if (existingIndex == -1) {
        _chats.insert(0, chat);
      }

      return chat;
    } catch (e) {
      _errorMessage.value = e.toString();
      print('ChatRepository: Error creating private chat: $e');
      return null;
    } finally {
      _isLoadingChats.value = false;
    }
  }

  // ============ MESSAGE OPERATIONS ============

  /// Load messages for a chat with deduplication
  Future<void> loadMessages(String chatId, {int page = 1, int limit = 50}) async {
    try {
      _isLoadingMessages.value = true;
      _errorMessage.value = '';

      final messages = await _chatService.getChatMessages(
        chatId: chatId,
        page: page,
        limit: limit,
      );

      if (page == 1) {
        // Clear messages and deduplication set for fresh load
        _messages.clear();
        _messageIds.clear();
        _localIdToServerId.clear();
      }

      // Add messages with deduplication
      // Messages from API are oldest-first, inserting at 0 makes newest end up at index 0
      // This is correct for ListView with reverse: true (newest at bottom)
      for (final message in messages) {
        _addMessageWithDeduplication(message);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      print('ChatRepository: Error loading messages: $e');
    } finally {
      _isLoadingMessages.value = false;
    }
  }

  /// Add a message with deduplication check
  void _addMessageWithDeduplication(ChatMessage message) {
    final key = message.deduplicationKey;

    // Skip if we already have this message
    if (_messageIds.contains(key)) {
      return;
    }

    // Check if this is a server response for a local optimistic message
    if (message.localId != null && _localIdToServerId.containsKey(message.localId)) {
      _replaceOptimisticMessage(message.localId!, message);
      return;
    }

    // Add new message
    _messageIds.add(key);
    _messages.insert(0, message);
  }

  /// Replace an optimistic message with the server response
  void _replaceOptimisticMessage(String localId, ChatMessage serverMessage) {
    final index = _messages.indexWhere((m) => m.localId == localId);
    if (index != -1) {
      // Remove old deduplication key
      _messageIds.remove(_messages[index].deduplicationKey);

      // Update message
      _messages[index] = serverMessage.copyWith(isLocalOnly: false);

      // Add new deduplication key
      _messageIds.add(serverMessage.deduplicationKey);

      // Track mapping
      if (serverMessage.id != null) {
        _localIdToServerId[localId] = serverMessage.id!;
      }
    }
  }

  /// Send a message via WebSocket ONLY (no dual channel)
  Future<ChatMessage?> sendMessage({
    required String chatId,
    required String content,
    MessageType messageType = MessageType.TEXT,
    List<MessageAttachment>? attachments,
    String? replyTo,
  }) async {
    if (content.trim().isEmpty) return null;
    if (_currentUserId == null) {
      _errorMessage.value = 'Not authenticated';
      return null;
    }

    try {
      _isSendingMessage.value = true;
      _errorMessage.value = '';

      // Generate a local ID for correlation
      final localId = const Uuid().v4();

      // Create optimistic message
      final optimisticMessage = ChatMessage(
        chatId: chatId,
        senderId: _currentUserId!,
        content: content.trim(),
        messageType: messageType,
        attachments: attachments,
        replyTo: replyTo,
        status: MessageStatus.SENT,
        isEdited: false,
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        localId: localId,
        isLocalOnly: true,
      );

      // Add optimistic message immediately
      _addMessageWithDeduplication(optimisticMessage);

      // Send via WebSocket ONLY (no API backup to prevent duplicates)
      _webSocketService.sendMessage(
        chatId: chatId,
        content: content.trim(),
        messageType: messageType,
        attachments: attachments,
        replyTo: replyTo,
        localId: localId,
      );

      return optimisticMessage;
    } catch (e) {
      _errorMessage.value = e.toString();
      print('ChatRepository: Error sending message: $e');
      return null;
    } finally {
      _isSendingMessage.value = false;
    }
  }

  /// Handle incoming message from WebSocket
  void handleIncomingMessage(ChatMessage message, {String? localId}) {
    final isCurrentChat = _currentChatId != null && message.chatId == _currentChatId;
    final isOwnMessage = message.senderId == _currentUserId;

    // Update the chat's lastMessage and lastActivity in the chats list
    _updateChatWithNewMessage(message);

    // Increment unread count if message is from another user and not in current chat
    if (!isOwnMessage && !isCurrentChat) {
      final currentCount = _unreadCounts[message.chatId] ?? 0;
      _unreadCounts[message.chatId] = currentCount + 1;
      // Trigger reactive update for badge
      _updateTotalUnreadCount();
    }

    // Only add to message list if it's for the current chat
    if (!isCurrentChat) {
      return;
    }

    // If this message has a localId AND we have an optimistic message with that localId,
    // it's a confirmation of our sent message. Otherwise, treat as new message.
    if (localId != null && _hasOptimisticMessage(localId)) {
      _replaceOptimisticMessage(localId, message);
    } else {
      // It's a new message from another user (or our message if no optimistic)
      _addMessageWithDeduplication(message);
    }
  }

  /// Check if we have a pending optimistic message with this localId
  bool _hasOptimisticMessage(String localId) {
    return _messages.any((m) => m.localId == localId && m.isLocalOnly);
  }

  /// Handle message error from WebSocket
  void handleMessageError(String error, {String? localId}) {
    if (localId != null) {
      // Find and update the optimistic message to show failed status
      final index = _messages.indexWhere((m) => m.localId == localId);
      if (index != -1) {
        _messages[index] = _messages[index].copyWith(status: MessageStatus.FAILED);
      }
    }
    _errorMessage.value = error;
  }

  // ============ MARK AS READ ============

  /// Mark messages as read for a chat
  Future<void> markMessagesAsRead(String chatId) async {
    if (_currentUserId == null) return;

    try {
      // Send via WebSocket for real-time update
      _webSocketService.markMessagesAsRead(chatId);

      // Also call API to persist
      await _chatService.markMessagesAsRead(chatId);

      // Update local unread count
      _unreadCounts[chatId] = 0;
      // Trigger reactive update for badge
      _updateTotalUnreadCount();

      // Update message statuses locally
      for (int i = 0; i < _messages.length; i++) {
        final msg = _messages[i];
        if (msg.chatId == chatId &&
            msg.senderId != _currentUserId &&
            msg.status != MessageStatus.READ) {
          _messages[i] = msg.copyWith(status: MessageStatus.READ);
        }
      }
    } catch (e) {
      print('ChatRepository: Error marking as read: $e');
    }
  }

  // ============ CHAT SESSION MANAGEMENT ============

  /// Enter a chat (load messages first, then join WebSocket room)
  Future<void> enterChat(String chatId) async {
    // Prevent duplicate entry
    if (_currentChatId == chatId && _messages.isNotEmpty) {
      return;
    }

    _currentChatId = chatId;

    // Load messages FIRST (important to prevent race conditions)
    await loadMessages(chatId);

    // THEN join the WebSocket room
    _webSocketService.joinChat(chatId);

    // Mark messages as read
    await markMessagesAsRead(chatId);
  }

  /// Exit current chat
  void exitChat() {
    if (_currentChatId != null) {
      _webSocketService.leaveChat();
      _currentChatId = null;
      _messages.clear();
      _messageIds.clear();
      _localIdToServerId.clear();
    }
  }

  // ============ TYPING INDICATORS ============

  final RxMap<String, bool> _typingUsers = <String, bool>{}.obs;
  Map<String, bool> get typingUsers => _typingUsers;

  void sendTypingIndicator(String chatId, bool isTyping) {
    _webSocketService.sendTypingIndicator(chatId, isTyping);
  }

  void handleTypingIndicator(String userId, bool isTyping) {
    if (isTyping) {
      _typingUsers[userId] = true;
    } else {
      _typingUsers.remove(userId);
    }
  }

  // ============ UTILITIES ============

  /// Clear all data (call on logout)
  void clear() {
    disconnectWebSocket();
    _chats.clear();
    _messages.clear();
    _messageIds.clear();
    _localIdToServerId.clear();
    _unreadCounts.clear();
    _totalUnreadCount.value = 0;
    _typingUsers.clear();
    _currentUserId = null;
    _currentChatId = null;
    _errorMessage.value = '';
  }

  /// Format time for display
  String formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }
}
