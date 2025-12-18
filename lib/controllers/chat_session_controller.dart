import 'dart:async';
import 'package:get/get.dart';
import '../models/chat_models.dart';
import '../repository/chat_repository.dart';
import '../controllers/auth_controller.dart';

/// Per-chat-room controller that manages the lifecycle of a single chat session
/// Created when entering a chat, disposed when exiting
///
/// Usage:
/// ```dart
/// // Create with unique tag per chat
/// final sessionController = Get.put(
///   ChatSessionController(chatId: 'abc123', chatName: 'Tour Chat'),
///   tag: 'chat_abc123',
/// );
///
/// // Dispose when leaving
/// Get.delete<ChatSessionController>(tag: 'chat_abc123');
/// ```
class ChatSessionController extends GetxController {
  final String chatId;
  final String chatName;

  late final ChatRepository _repository;
  late final AuthController _authController;

  // Typing indicator debounce
  Timer? _typingTimer;
  static const _typingDebounceMs = 1000;
  bool _isCurrentlyTyping = false;

  ChatSessionController({
    required this.chatId,
    required this.chatName,
  });

  @override
  void onInit() {
    super.onInit();
    _repository = Get.find<ChatRepository>();
    _authController = Get.find<AuthController>();

    // Enter the chat after build is complete to avoid setState during build
    Future.microtask(() => _enterChat());
  }

  @override
  void onClose() {
    _typingTimer?.cancel();
    // Stop typing indicator if was typing
    if (_isCurrentlyTyping) {
      _repository.sendTypingIndicator(chatId, false);
    }
    // Exit the chat
    _repository.exitChat();
    super.onClose();
  }

  // ============ GETTERS ============

  List<ChatMessage> get messages => _repository.messages;
  bool get isLoading => _repository.isLoadingMessages;
  bool get isSendingMessage => _repository.isSendingMessage;
  String get errorMessage => _repository.errorMessage;
  Map<String, bool> get typingUsers => _repository.typingUsers;
  String get currentUserId => _authController.userId;

  /// Get the current chat with participants
  Chat? get currentChat => _repository.chats.firstWhereOrNull((c) => c.id == chatId);

  /// Get participants of current chat
  List<ChatParticipant> get participants => currentChat?.participants ?? [];

  // ============ CHAT LIFECYCLE ============

  /// Enter the chat room
  /// Important: Loads messages FIRST, THEN joins WebSocket room to prevent race conditions
  Future<void> _enterChat() async {
    await _repository.enterChat(chatId);
  }

  /// Reload messages (pull-to-refresh)
  Future<void> refreshMessages() async {
    await _repository.loadMessages(chatId);
  }

  /// Load more messages (pagination)
  Future<void> loadMoreMessages({int page = 1}) async {
    await _repository.loadMessages(chatId, page: page);
  }

  // ============ MESSAGE OPERATIONS ============

  /// Send a message
  Future<void> sendMessage({
    required String content,
    MessageType messageType = MessageType.TEXT,
    List<MessageAttachment>? attachments,
    String? replyTo,
  }) async {
    // Stop typing indicator when sending
    if (_isCurrentlyTyping) {
      _stopTyping();
    }

    await _repository.sendMessage(
      chatId: chatId,
      content: content,
      messageType: messageType,
      attachments: attachments,
      replyTo: replyTo,
    );
  }

  /// Mark all messages as read
  Future<void> markAsRead() async {
    await _repository.markMessagesAsRead(chatId);
  }

  // ============ TYPING INDICATORS ============

  /// Call when user starts typing (with debounce)
  void onUserTyping() {
    // Cancel existing timer
    _typingTimer?.cancel();

    // Send typing start if not already typing
    if (!_isCurrentlyTyping) {
      _isCurrentlyTyping = true;
      _repository.sendTypingIndicator(chatId, true);
    }

    // Set timer to stop typing after debounce period
    _typingTimer = Timer(Duration(milliseconds: _typingDebounceMs), () {
      _stopTyping();
    });
  }

  /// Stop typing indicator
  void _stopTyping() {
    _typingTimer?.cancel();
    if (_isCurrentlyTyping) {
      _isCurrentlyTyping = false;
      _repository.sendTypingIndicator(chatId, false);
    }
  }

  /// Get formatted typing indicator text
  String? get typingIndicatorText {
    final users = typingUsers.keys.where((id) => typingUsers[id] == true).toList();
    if (users.isEmpty) return null;

    if (users.length == 1) {
      return 'typing...';
    } else if (users.length == 2) {
      return '2 people typing...';
    } else {
      return '${users.length} people typing...';
    }
  }

  // ============ UTILITIES ============

  /// Check if a message was sent by the current user
  bool isOwnMessage(ChatMessage message) {
    return message.senderId == currentUserId;
  }

  /// Format message time for display
  String formatMessageTime(DateTime dateTime) {
    return _repository.formatMessageTime(dateTime);
  }

  void clearError() {
    _repository.clearError();
  }
}

/// Extension to easily create and manage chat session controllers
extension ChatSessionControllerExtension on GetInterface {
  /// Create or get existing chat session controller
  ChatSessionController createChatSession({
    required String chatId,
    required String chatName,
  }) {
    final tag = 'chat_session_$chatId';

    // Check if already exists
    if (Get.isRegistered<ChatSessionController>(tag: tag)) {
      return Get.find<ChatSessionController>(tag: tag);
    }

    // Create new session controller
    return Get.put(
      ChatSessionController(chatId: chatId, chatName: chatName),
      tag: tag,
    );
  }

  /// Delete chat session controller
  void deleteChatSession(String chatId) {
    final tag = 'chat_session_$chatId';
    if (Get.isRegistered<ChatSessionController>(tag: tag)) {
      Get.delete<ChatSessionController>(tag: tag);
    }
  }
}
