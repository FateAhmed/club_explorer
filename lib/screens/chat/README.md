# Flutter Chat Implementation with GetX

This implementation provides a complete chat system for your Flutter app using GetX state management and real-time WebSocket communication.

## Features

- ✅ **GetX State Management** - Reactive UI updates
- ✅ **Real-time Messaging** - WebSocket support for instant communication
- ✅ **API Integration** - RESTful API calls for chat operations
- ✅ **Message Types** - Support for text, images, files, and more
- ✅ **Typing Indicators** - See when others are typing
- ✅ **Read Status** - Track message read status
- ✅ **Optimistic Updates** - Instant UI feedback
- ✅ **Error Handling** - Comprehensive error management

## Setup Instructions

### 1. Add Dependencies

Add these dependencies to your `pubspec.yaml`:

```yaml
dependencies:
  get: ^4.6.6
  http: ^1.1.0
  web_socket_channel: ^2.4.0
```

### 2. Update Backend URLs

Update the URLs in `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://your-backend-url:7043';
  static const String websocketUrl = 'ws://your-backend-url:7043';
  
  // For production
  static const String productionBaseUrl = 'https://your-production-api.com';
  static const String productionWebsocketUrl = 'wss://your-production-api.com';
}
```

### 3. Set Authentication Token

In your app initialization, set the auth token:

```dart
final chatController = Get.find<ChatController>();
chatController._chatService.setAuthToken('your_auth_token');
```

## File Structure

```
lib/
├── models/
│   └── chat_models.dart          # Chat data models
├── services/
│   ├── chat_service.dart         # API service
│   └── websocket_service.dart    # WebSocket service
├── controllers/
│   └── chat_controller.dart      # GetX controller
└── screens/chat/
    ├── messages_screen.dart      # Chat list screen
    ├── chat.dart                 # Individual chat screen
    └── README.md                 # This file
```

## Usage Examples

### 1. Initialize Chat Controller

```dart
// In your main app or screen
final ChatController chatController = Get.put(ChatController());
```

### 2. Load User Chats

```dart
await chatController.loadUserChats();
```

### 3. Send a Message

```dart
await chatController.sendMessage(
  chatId: 'chat123',
  content: 'Hello everyone!',
  messageType: MessageType.TEXT,
);
```

### 4. Chat Creation

Chats are automatically created by the backend when users book tours. No manual chat creation is needed.

### 5. Join a Chat

```dart
final chat = await chatController.loadChatByTourId('tour123');
chatController.setCurrentChat(chat);
```

## API Endpoints Used

- `GET /api/chat/user` - Get user's chats
- `GET /api/chat/tour/:tourId` - Get chat by tour ID
- `POST /api/chat/:chatId/messages` - Send message
- `GET /api/chat/:chatId/messages` - Get chat messages
- `PUT /api/chat/messages/:messageId` - Update message
- `DELETE /api/chat/messages/:messageId` - Delete message
- `PUT /api/chat/:chatId/read` - Mark messages as read

## URL Configuration

All URLs are centrally managed in `lib/config/api_config.dart`:

```dart
// Development URLs
static const String baseUrl = 'http://localhost:7043';
static const String websocketUrl = 'ws://localhost:7043';

// Production URLs
static const String productionBaseUrl = 'https://your-production-api.com';
static const String productionWebsocketUrl = 'wss://your-production-api.com';
```

## WebSocket Events

### Client to Server
- `join_chat` - Join a chat room
- `send_message` - Send a message
- `typing_start` - Start typing indicator
- `typing_stop` - Stop typing indicator
- `mark_messages_read` - Mark messages as read

### Server to Client
- `new_message` - New message received
- `user_joined` - User joined chat
- `user_typing` - User typing status
- `messages_read` - Messages marked as read
- `error` - Error occurred

## Customization

### 1. Message Types

Add new message types in `chat_models.dart`:

```dart
enum MessageType {
  TEXT,
  IMAGE,
  FILE,
  LOCATION,
  SYSTEM,
  ANNOUNCEMENT,
  POLL,
  EVENT,
  // Add your custom types here
}
```

### 2. UI Customization

Modify the UI components in `messages_screen.dart` and `chat.dart` to match your app's design.

### 3. Error Handling

Customize error handling in the controller methods to show appropriate messages to users.

## Testing

### 1. Test API Connection

```dart
final chatController = Get.put(ChatController());
await chatController.loadUserChats();
```

### 2. Test WebSocket Connection

Check the console for WebSocket connection messages.

### 3. Test Real-time Messaging

Open the app on multiple devices and send messages to test real-time functionality.

## Troubleshooting

### 1. WebSocket Connection Issues

- Check if the backend WebSocket server is running
- Verify the WebSocket URL is correct
- Check network connectivity

### 2. API Connection Issues

- Verify the backend API URL is correct
- Check if authentication token is set
- Ensure the backend server is running

### 3. Message Not Sending

- Check if the user is a participant in the chat
- Verify the chat ID is correct
- Check for network errors

## Future Enhancements

- [ ] Message reactions and emojis
- [ ] Voice messages
- [ ] File upload support
- [ ] Push notifications
- [ ] Message search
- [ ] Chat export
- [ ] Message encryption
- [ ] Chat moderation tools

## Support

For issues or questions, please check the backend API documentation or contact the development team.
