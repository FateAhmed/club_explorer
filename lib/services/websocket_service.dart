import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../models/chat_models.dart';

/// Callback types for repository integration
typedef OnMessageReceived = void Function(ChatMessage message, String? localId);
typedef OnMessageError = void Function(String error, String? localId);
typedef OnTypingIndicator = void Function(String userId, bool isTyping);
typedef OnConnectionStatusChanged = void Function(bool isConnected);
typedef OnChatNotification = void Function(Map<String, dynamic> data);

class WebSocketService {
  static WebSocketService? _instance;
  IO.Socket? _socket;
  String? _userId;
  String? _currentChatId;
  bool _isConnected = false;

  // Exponential backoff settings
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const int _baseReconnectDelay = 1000; // 1 second
  static const int _maxReconnectDelay = 30000; // 30 seconds
  Timer? _reconnectTimer;
  String? _serverUrl;

  // Callbacks for repository integration
  OnMessageReceived? onMessageReceived;
  OnMessageError? onMessageError;
  OnTypingIndicator? onTypingIndicator;
  OnConnectionStatusChanged? onConnectionStatusChanged;
  OnChatNotification? onChatNotification;

  // Singleton pattern
  static WebSocketService get instance {
    _instance ??= WebSocketService._();
    return _instance!;
  }

  WebSocketService._();

  bool get isConnected => _isConnected;
  String? get currentChatId => _currentChatId;

  // Connect to Socket.IO server
  void connect(String serverUrl, String userId) {
    if (_isConnected && _userId == userId) return;

    _serverUrl = serverUrl;
    _userId = userId;
    _reconnectAttempts = 0;

    _connectInternal();
  }

  void _connectInternal() {
    try {
      // Dispose existing socket if any
      _socket?.dispose();

      _socket = IO.io(_serverUrl!, <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'reconnection': false, // We handle reconnection ourselves
      });

      _socket!.connect();

      _socket!.on('connect', (_) {
        _isConnected = true;
        _reconnectAttempts = 0;
        onConnectionStatusChanged?.call(true);

        // Authenticate to join user's notification room for realtime updates
        if (_userId != null) {
          _socket!.emit('authenticate', {'userId': _userId});
        }

        // Rejoin current chat room if any
        if (_currentChatId != null) {
          joinChat(_currentChatId!);
        }
      });

      _socket!.on('disconnect', (_) {
        _handleDisconnect();
      });

      _socket!.on('connect_error', (error) {
        debugPrint('Socket.IO connection error: $error');
        _handleDisconnect();
      });

      _socket!.on('error', (error) {
        _handleError(error);
      });

      // Listen for chat events
      _socket!.on('new_message', (data) => _handleNewMessage(data));
      _socket!.on('message_error', (data) => _handleMessageError(data));
      _socket!.on('user_joined', (data) => _handleUserJoined(data));
      _socket!.on('user_typing', (data) => _handleUserTyping(data));
      _socket!.on('messages_read', (data) => _handleMessagesRead(data));
      _socket!.on('chat_notification', (data) => _handleChatNotification(data));
    } catch (e) {
      debugPrint('Socket.IO connection error: $e');
      _isConnected = false;
      onConnectionStatusChanged?.call(false);
      _scheduleReconnect();
    }
  }

  // Disconnect from Socket.IO server
  void disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = _maxReconnectAttempts; // Prevent auto-reconnect

    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      _currentChatId = null;
      onConnectionStatusChanged?.call(false);
    }
  }

  // Join a chat room
  void joinChat(String chatId) {
    // Always store the chat ID so we can join when connected
    _currentChatId = chatId;

    if (!_isConnected || _socket == null) {
      return;
    }

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

  // Send a message with localId for correlation
  void sendMessage({
    required String chatId,
    required String content,
    MessageType messageType = MessageType.TEXT,
    List<MessageAttachment>? attachments,
    String? replyTo,
    String? localId,
  }) {
    if (!_isConnected || _socket == null) {
      onMessageError?.call('Not connected to server', localId);
      return;
    }

    _socket!.emit('send_message', {
      'chatId': chatId,
      'senderId': _userId,
      'content': content,
      'messageType': messageType.toString().split('.').last.toLowerCase(),
      'attachments': attachments?.map((e) => e.toJson()).toList(),
      'replyTo': replyTo,
      'localId': localId,
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

  // Handle new message
  void _handleNewMessage(Map<String, dynamic> data) {
    try {
      final messageData = data['message'];
      if (messageData == null) {
        return;
      }

      final message = ChatMessage.fromJson(messageData);
      final localId = data['localId'] as String?;

      // Use callback (repository pattern)
      if (onMessageReceived != null) {
        onMessageReceived!(message, localId);
      }
    } catch (e) {
      debugPrint('Error handling new message: $e');
    }
  }

  // Handle message error
  void _handleMessageError(Map<String, dynamic> data) {
    try {
      final error = data['error'] as String? ?? 'Unknown error';
      final localId = data['localId'] as String?;

      if (onMessageError != null) {
        onMessageError!(error, localId);
      }
    } catch (e) {
      debugPrint('Error handling message error: $e');
    }
  }

  // Handle user joined
  void _handleUserJoined(Map<String, dynamic> data) {
    // User joined event received
  }

  // Handle user typing
  void _handleUserTyping(Map<String, dynamic> data) {
    final userId = data['userId'] as String?;
    final isTyping = data['isTyping'] as bool? ?? false;

    if (userId != null && onTypingIndicator != null) {
      onTypingIndicator!(userId, isTyping);
    }
  }

  // Handle messages read
  void _handleMessagesRead(Map<String, dynamic> data) {
    // Messages read event received
  }

  // Handle chat notification (for realtime updates on chat list)
  void _handleChatNotification(dynamic data) {
    if (data is Map<String, dynamic> && onChatNotification != null) {
      onChatNotification!(data);
    }
  }

  // Handle errors
  void _handleError(dynamic error) {
    debugPrint('Socket.IO error: $error');
  }

  // Handle disconnection with exponential backoff
  void _handleDisconnect() {
    _isConnected = false;
    onConnectionStatusChanged?.call(false);
    _scheduleReconnect();
  }

  // Schedule reconnection with exponential backoff
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      return;
    }

    _reconnectTimer?.cancel();

    // Calculate delay with exponential backoff
    final delay = _calculateReconnectDelay();
    _reconnectAttempts++;

    _reconnectTimer = Timer(Duration(milliseconds: delay), () {
      if (_userId != null && _serverUrl != null) {
        _connectInternal();
      }
    });
  }

  // Calculate reconnect delay with exponential backoff
  int _calculateReconnectDelay() {
    // Exponential backoff: base * 2^attempts, capped at max
    final delay = _baseReconnectDelay * (1 << _reconnectAttempts);
    return delay.clamp(0, _maxReconnectDelay);
  }

  // Reset reconnection state
  void resetReconnection() {
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
}
