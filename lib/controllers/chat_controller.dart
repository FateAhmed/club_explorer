import 'package:get/get.dart';
import '../models/chat_models.dart';
import '../services/chat_service.dart';
import '../services/websocket_service.dart';
import '../config/api_config.dart';
import 'auth_controller.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final WebSocketService _webSocketService = WebSocketService.instance;

  // Observable variables
  final RxList<Chat> _chats = <Chat>[].obs;
  final RxList<ChatMessage> _messages = <ChatMessage>[].obs;
  final Rx<Chat?> _currentChat = Rx<Chat?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isSendingMessage = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxMap<String, bool> _typingUsers = <String, bool>{}.obs;

  // Getters
  List<Chat> get chats => _chats;
  List<ChatMessage> get messages => _messages;
  Chat? get currentChat => _currentChat.value;
  bool get isLoading => _isLoading.value;
  bool get isSendingMessage => _isSendingMessage.value;
  String get errorMessage => _errorMessage.value;
  Map<String, bool> get typingUsers => _typingUsers;
  ChatService get chatService => _chatService; // Expose for debugging

  @override
  void onInit() {
    super.onInit();
    // Set auth token from AuthController
    _setAuthToken();

    // Don't connect to WebSocket automatically - connect only when needed
    // _webSocketService.connect(ApiConfig.currentWebsocketUrl, 'current_user');
  }

  // Set auth token from AuthController
  void _setAuthToken() {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn && authController.token.isNotEmpty) {
        _chatService.setAuthToken(authController.token);
      }
    } catch (e) {
      print('Error setting auth token: $e');
    }
  }

  // Connect to WebSocket with actual user ID
  void connectWebSocket() {
    try {
      final authController = Get.find<AuthController>();
      if (authController.isLoggedIn && authController.userData.isNotEmpty) {
        final userId = authController.userData['_id'] ?? authController.userData['id'];
        if (userId != null) {
          _webSocketService.connect(ApiConfig.currentWebsocketUrl, userId.toString());
        }
      }
    } catch (e) {
      print('Error connecting WebSocket: $e');
    }
  }

  // Test API connection
  Future<void> testApiConnection() async {
    try {
      print('Testing API connection to: ${ApiConfig.currentApiBaseUrl}');
      _setAuthToken();

      // Test with a simple endpoint
      final response = await _chatService.getUserChats();
      print('API test successful: ${response.length} chats found');
      Get.snackbar('Success', 'API connection successful!');
    } catch (e) {
      print('API test failed: $e');
      Get.snackbar('Error', 'API test failed: $e');
    }
  }

  @override
  void onClose() {
    _webSocketService.disconnect();
    super.onClose();
  }

  // Chat Management Methods
  Future<void> loadUserChats() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Ensure auth token is set before making API call
      _setAuthToken();

      print('Loading user chats from: ${ApiConfig.getUserChats}');
      print('Auth token set: ${_chatService.authToken != null}');

      final chats = await _chatService.getUserChats();
      _chats.assignAll(chats);

      print('Successfully loaded ${chats.length} chats');
    } catch (e) {
      _errorMessage.value = e.toString();
      print('Error loading chats: $e');
      Get.snackbar('Error', 'Failed to load chats: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loadChatByTourId(String tourId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Ensure auth token is set before making API call
      _setAuthToken();

      final chat = await _chatService.getChatByTourId(tourId);
      _currentChat.value = chat;
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load chat: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  // Message Management Methods
  Future<void> loadMessages(String chatId, {int page = 1, int limit = 50}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Ensure auth token is set before making API call
      _setAuthToken();

      final messages = await _chatService.getChatMessages(
        chatId: chatId,
        page: page,
        limit: limit,
      );

      if (page == 1) {
        _messages.assignAll(messages.reversed.toList());
      } else {
        _messages.insertAll(0, messages.reversed.toList());
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load messages: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> sendMessage({
    required String chatId,
    required String content,
    MessageType messageType = MessageType.TEXT,
    List<MessageAttachment>? attachments,
    String? replyTo,
  }) async {
    if (content.trim().isEmpty) return;

    try {
      _isSendingMessage.value = true;
      _errorMessage.value = '';

      // Create optimistic message
      final optimisticMessage = ChatMessage(
        chatId: chatId,
        senderId: 'current_user', // Replace with actual user ID
        content: content,
        messageType: messageType,
        attachments: attachments,
        replyTo: replyTo,
        status: MessageStatus.SENT,
        isEdited: false,
        isDeleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _messages.add(optimisticMessage);

      // Send via WebSocket for real-time delivery
      _webSocketService.sendMessage(
        chatId: chatId,
        content: content,
        messageType: messageType,
        attachments: attachments,
        replyTo: replyTo,
      );

      // Also send via API as backup
      try {
        // Ensure auth token is set before making API call
        _setAuthToken();

        await _chatService.sendMessage(
          chatId: chatId,
          content: content,
          messageType: messageType,
          attachments: attachments,
          replyTo: replyTo,
        );
      } catch (e) {
        print('API backup send failed: $e');
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to send message: $e');

      // Remove optimistic message on error
      _messages.removeWhere((m) => m.content == content && m.senderId == 'current_user');
    } finally {
      _isSendingMessage.value = false;
    }
  }

  Future<void> updateMessage(String messageId, String content) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final message = await _chatService.updateMessage(
        messageId: messageId,
        content: content,
      );

      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages[index] = message;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to update message: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      await _chatService.deleteMessage(messageId);

      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        _messages.removeAt(index);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to delete message: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      // Send via WebSocket for real-time updates
      _webSocketService.markMessagesAsRead(chatId);

      // Also send via API as backup
      try {
        await _chatService.markMessagesAsRead(chatId);
      } catch (e) {
        print('API backup mark as read failed: $e');
      }

      // Update message status locally
      for (int i = 0; i < _messages.length; i++) {
        if (_messages[i].chatId == chatId &&
            _messages[i].senderId != 'current_user' &&
            _messages[i].status != MessageStatus.READ) {
          _messages[i] = ChatMessage(
            id: _messages[i].id,
            chatId: _messages[i].chatId,
            senderId: _messages[i].senderId,
            content: _messages[i].content,
            messageType: _messages[i].messageType,
            attachments: _messages[i].attachments,
            replyTo: _messages[i].replyTo,
            status: MessageStatus.READ,
            editedAt: _messages[i].editedAt,
            deletedAt: _messages[i].deletedAt,
            isEdited: _messages[i].isEdited,
            isDeleted: _messages[i].isDeleted,
            metadata: _messages[i].metadata,
            createdAt: _messages[i].createdAt,
            updatedAt: _messages[i].updatedAt,
          );
        }
      }
    } catch (e) {
      _errorMessage.value = e.toString();
    }
  }

  // Utility Methods
  void setCurrentChat(Chat? chat) {
    // Leave previous chat if any
    if (_currentChat.value != null) {
      _webSocketService.leaveChat();
    }

    _currentChat.value = chat;
    if (chat != null) {
      loadMessages(chat.id!);
      // Join new chat room
      _webSocketService.joinChat(chat.id!);
    }
  }

  void clearMessages() {
    _messages.clear();
  }

  // Add message from WebSocket
  void addMessage(ChatMessage message) {
    _messages.add(message);
  }

  void clearError() {
    _errorMessage.value = '';
  }

  void setTyping(String userId, bool isTyping) {
    _typingUsers[userId] = isTyping;
  }

  void clearTyping() {
    _typingUsers.clear();
  }

  // Get unread message count for a chat
  int getUnreadCount(String chatId) {
    return _messages
        .where((message) =>
            message.chatId == chatId &&
            message.senderId != 'current_user' &&
            message.status != MessageStatus.READ)
        .length;
  }

  // Get last message for a chat
  ChatMessage? getLastMessage(String chatId) {
    final chatMessages = _messages.where((m) => m.chatId == chatId).toList();
    if (chatMessages.isEmpty) return null;

    chatMessages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return chatMessages.first;
  }

  // Format time for display
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
}
