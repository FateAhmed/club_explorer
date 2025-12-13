import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_models.dart';
import '../config/api_config.dart';

class ChatService {
  String? authToken;

  ChatService({this.authToken});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (authToken != null) 'Authorization': 'Bearer $authToken',
      };

  // Chat Management APIs

  Future<List<Chat>> getUserChats() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.getUserChats),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['chats'] as List).map((chat) => Chat.fromJson(chat)).toList();
      } else {
        throw Exception('Failed to fetch user chats: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching user chats: $e');
    }
  }

  Future<Chat> getChatByTourId(String tourId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getChatByTourId}/$tourId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Chat.fromJson(data['chat']);
      } else {
        throw Exception('Failed to fetch chat: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching chat: $e');
    }
  }

  // Message APIs
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String content,
    MessageType messageType = MessageType.TEXT,
    List<MessageAttachment>? attachments,
    String? replyTo,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.sendMessage}/$chatId/messages'),
        headers: _headers,
        body: jsonEncode({
          'content': content,
          'messageType': messageType.toString().split('.').last,
          'attachments': attachments?.map((e) => e.toJson()).toList(),
          'replyTo': replyTo,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return ChatMessage.fromJson(data['message']);
      } else {
        throw Exception('Failed to send message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  Future<List<ChatMessage>> getChatMessages({
    required String chatId,
    int page = 1,
    int limit = 50,
    MessageType? messageType,
  }) async {
    try {
      String url = '${ApiConfig.getChatMessages}/$chatId/messages?page=$page&limit=$limit';
      if (messageType != null) {
        url += '&messageType=${messageType.toString().split('.').last}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['messages'] as List).map((message) => ChatMessage.fromJson(message)).toList();
      } else {
        throw Exception('Failed to fetch messages: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching messages: $e');
    }
  }

  Future<ChatMessage> updateMessage({
    required String messageId,
    required String content,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.updateMessage}/$messageId'),
        headers: _headers,
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ChatMessage.fromJson(data['message']);
      } else {
        throw Exception('Failed to update message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating message: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.deleteMessage}/$messageId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete message: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  Future<void> markMessagesAsRead(String chatId) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.markMessagesAsRead}/$chatId/read'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark messages as read: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error marking messages as read: $e');
    }
  }

  // Helper method to set auth token
  void setAuthToken(String token) {
    authToken = token;
  }
}
