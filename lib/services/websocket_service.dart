import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_models.dart';
import '../controllers/chat_controller.dart';
import '../config/api_config.dart';
import 'package:get/get.dart';

class WebSocketService {
  static WebSocketService? _instance;
  IO.Socket? _socket;
  String? _userId;
  String? _currentChatId;
  bool _isConnected = false;

  // Singleton pattern
  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  WebSocketService._();

  bool get isConnected => _isConnected;

  // Connect to Socket.IO server
  void connect(String serverUrl, String userId) {
    if (_isConnected) return;

    _userId = userId;
    try {
      _socket = IO.io(serverUrl, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      _socket!.connect();

      _socket!.on('connect', (_) {
        _isConnected = true;
        print('Socket.IO connected successfully');
      });

      _socket!.on('disconnect', (_) {
        _handleDisconnect();
      });

      _socket!.on('error', (error) {
        _handleError(error);
      });

      // Listen for chat events
      _socket!.on('new_message', (data) => _handleMessage({'event': 'new_message', 'data': data}));
      _socket!.on('user_joined', (data) => _handleMessage({'event': 'user_joined', 'data': data}));
      _socket!.on('user_typing', (data) => _handleMessage({'event': 'user_typing', 'data': data}));
      _socket!.on('messages_read', (data) => _handleMessage({'event': 'messages_read', 'data': data}));
    } catch (e) {
      print('Socket.IO connection error: $e');
      _isConnected = false;
    }
  }

  // Disconnect from Socket.IO server
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      print('Socket.IO disconnected');
    }
  }

  // Join a chat room
  void joinChat(String chatId) {
    if (!_isConnected || _socket == null) return;

    _currentChatId = chatId;
    _socket!.emit('join_chat', {
      'userId': _userId,
      'chatId': chatId,
    });
  }

  // Leave current chat room
  void leaveChat() {
    if (!_isConnected || _socket == null || _currentChatId == null) return;

    _socket!.emit('leave_chat', {
      'userId': _userId,
      'chatId': _currentChatId,
    });

    _currentChatId = null;
  }

  // Send a message
  void sendMessage({
    required String chatId,
    required String content,
    MessageType messageType = MessageType.TEXT,
    List<MessageAttachment>? attachments,
    String? replyTo,
  }) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('send_message', {
      'chatId': chatId,
      'senderId': _userId,
      'content': content,
      'messageType': messageType.toString().split('.').last,
      'attachments': attachments?.map((e) => e.toJson()).toList(),
      'replyTo': replyTo,
    });
  }

  // Send typing indicator
  void sendTypingIndicator(String chatId, bool isTyping) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit(isTyping ? 'typing_start' : 'typing_stop', {
      'chatId': chatId,
      'userId': _userId,
    });
  }

  // Mark messages as read
  void markMessagesAsRead(String chatId) {
    if (!_isConnected || _socket == null) return;

    _socket!.emit('mark_messages_read', {
      'chatId': chatId,
      'userId': _userId,
    });
  }

  // Handle incoming messages
  void _handleMessage(Map<String, dynamic> message) {
    try {
      final event = message['event'];
      final eventData = message['data'];

      switch (event) {
        case 'new_message':
          _handleNewMessage(eventData);
          break;
        case 'user_joined':
          _handleUserJoined(eventData);
          break;
        case 'user_typing':
          _handleUserTyping(eventData);
          break;
        case 'messages_read':
          _handleMessagesRead(eventData);
          break;
        case 'error':
          _handleError(eventData['message']);
          break;
        default:
          print('Unknown Socket.IO event: $event');
      }
    } catch (e) {
      print('Error handling Socket.IO message: $e');
    }
  }

  // Handle new message
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final message = ChatMessage.fromJson(data['message']);

      // Update chat controller
      final chatController = Get.find<ChatController>();
      chatController.addMessage(message);
    } catch (e) {
      print('Error handling new message: $e');
    }
  }

  // Handle user joined
  void _handleUserJoined(Map<String, dynamic> data) {
    print('User ${data['userId']} joined chat ${data['chatId']}');
    // You can add UI updates here if needed
  }

  // Handle user typing
  void _handleUserTyping(Map<String, dynamic> data) {
    final chatController = Get.find<ChatController>();
    chatController.setTyping(
      data['userId'],
      data['isTyping'] ?? false,
    );
  }

  // Handle messages read
  void _handleMessagesRead(Map<String, dynamic> data) {
    print('Messages read by ${data['userId']} in chat ${data['chatId']}');
    // You can add UI updates here if needed
  }

  // Handle errors
  void _handleError(dynamic error) {
    print('Socket.IO error: $error');
    Get.snackbar('Connection Error', error.toString());
  }

  // Handle disconnection
  void _handleDisconnect() {
    _isConnected = false;
    print('Socket.IO disconnected');
    Get.snackbar('Connection Lost', 'Socket.IO connection lost. Trying to reconnect...');

    // Attempt to reconnect after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (_userId != null) {
        connect(ApiConfig.wsUrl, _userId!);
      }
    });
  }
}
