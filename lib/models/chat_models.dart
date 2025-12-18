class ChatMessage {
  final String? id;
  final String chatId;
  final String senderId;
  final String? senderName;
  final String content;
  final MessageType messageType;
  final List<MessageAttachment>? attachments;
  final String? replyTo;
  final MessageStatus status;
  final DateTime? editedAt;
  final DateTime? deletedAt;
  final bool isEdited;
  final bool isDeleted;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  // For optimistic updates and deduplication
  final String? localId;
  final bool isLocalOnly;

  ChatMessage({
    this.id,
    required this.chatId,
    required this.senderId,
    this.senderName,
    required this.content,
    required this.messageType,
    this.attachments,
    this.replyTo,
    required this.status,
    this.editedAt,
    this.deletedAt,
    required this.isEdited,
    required this.isDeleted,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.localId,
    this.isLocalOnly = false,
  });

  /// Unique key for deduplication
  /// Uses server ID if available, otherwise uses localId
  String get deduplicationKey => id ?? localId ?? '${chatId}_${senderId}_${createdAt.millisecondsSinceEpoch}';

  /// Creates a copy of this message with updated fields
  ChatMessage copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? content,
    MessageType? messageType,
    List<MessageAttachment>? attachments,
    String? replyTo,
    MessageStatus? status,
    DateTime? editedAt,
    DateTime? deletedAt,
    bool? isEdited,
    bool? isDeleted,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? localId,
    bool? isLocalOnly,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      messageType: messageType ?? this.messageType,
      attachments: attachments ?? this.attachments,
      replyTo: replyTo ?? this.replyTo,
      status: status ?? this.status,
      editedAt: editedAt ?? this.editedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      localId: localId ?? this.localId,
      isLocalOnly: isLocalOnly ?? this.isLocalOnly,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? json['id'],
      chatId: json['chatId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'],
      content: json['content'] ?? '',
      messageType: _parseMessageType(json['messageType']),
      attachments: json['attachments'] != null
          ? (json['attachments'] as List).map((e) => MessageAttachment.fromJson(e)).toList()
          : null,
      replyTo: json['replyTo'],
      status: _parseMessageStatus(json['status']),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      isEdited: json['isEdited'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      metadata: json['metadata'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
      localId: json['localId'],
      isLocalOnly: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'messageType': _messageTypeToString(messageType),
      'attachments': attachments?.map((e) => e.toJson()).toList(),
      'replyTo': replyTo,
      'status': _messageStatusToString(status),
      'isEdited': isEdited,
      'isDeleted': isDeleted,
      'metadata': metadata,
      if (localId != null) 'localId': localId,
    };
  }
}

class Chat {
  final String? id;
  final ChatType chatType;
  final String? tourId;  // Optional - only for group tour chats
  final DateTime? startDate;  // Optional - for tour group chats, identifies departure
  final String name;
  final String? description;
  final List<ChatParticipant> participants;
  final ChatStatus status;
  final ChatMessage? lastMessage;
  final DateTime lastActivity;
  final ChatSettings settings;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chat({
    this.id,
    required this.chatType,
    this.tourId,
    this.startDate,
    required this.name,
    this.description,
    required this.participants,
    required this.status,
    this.lastMessage,
    required this.lastActivity,
    required this.settings,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper to check if chat is a group chat
  bool get isGroupChat => chatType == ChatType.GROUP;

  // Helper to check if chat is a private chat
  bool get isPrivateChat => chatType == ChatType.PRIVATE;

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'] ?? json['id'],
      chatType: _parseChatType(json['chatType']),
      tourId: json['tourId'],
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      name: json['name'] ?? '',
      description: json['description'],
      participants: json['participants'] != null
          ? (json['participants'] as List).map((e) => ChatParticipant.fromJson(e)).toList()
          : [],
      status: _parseChatStatus(json['status']),
      lastMessage: json['lastMessage'] != null && json['lastMessage'] is Map
          ? ChatMessage.fromJson(json['lastMessage'])
          : null,
      lastActivity: DateTime.parse(json['lastActivity']),
      settings: ChatSettings.fromJson(json['settings'] ?? {}),
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class ChatParticipant {
  final String userId;
  final String? name;
  final String? email;
  final String? profileImage;
  final ChatRole role;
  final DateTime joinedAt;
  final DateTime? lastSeen;
  final DateTime? lastReadAt;
  final int unreadCount;
  final bool isActive;
  final Map<String, dynamic>? metadata;

  ChatParticipant({
    required this.userId,
    this.name,
    this.email,
    this.profileImage,
    required this.role,
    required this.joinedAt,
    this.lastSeen,
    this.lastReadAt,
    this.unreadCount = 0,
    required this.isActive,
    this.metadata,
  });

  /// Get display name: name > email > userId
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (email != null && email!.isNotEmpty) return email!;
    return 'User ${userId.substring(0, 8)}...';
  }

  /// Check if participant has a profile image
  bool get hasProfileImage => profileImage != null && profileImage!.isNotEmpty;

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      userId: json['userId'] ?? '',
      name: json['name'],
      email: json['email'],
      profileImage: json['profileImage'],
      role: _parseChatRole(json['role']),
      joinedAt: json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : DateTime.now(),
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      lastReadAt: json['lastReadAt'] != null ? DateTime.parse(json['lastReadAt']) : null,
      unreadCount: json['unreadCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      metadata: json['metadata'],
    );
  }
}

class ChatSettings {
  final bool allowFileUploads;
  final bool allowImageUploads;
  final bool allowLocationSharing;
  final int? maxParticipants;
  final bool isPublic;

  ChatSettings({
    required this.allowFileUploads,
    required this.allowImageUploads,
    required this.allowLocationSharing,
    this.maxParticipants,
    required this.isPublic,
  });

  factory ChatSettings.fromJson(Map<String, dynamic> json) {
    return ChatSettings(
      allowFileUploads: json['allowFileUploads'] ?? true,
      allowImageUploads: json['allowImageUploads'] ?? true,
      allowLocationSharing: json['allowLocationSharing'] ?? true,
      maxParticipants: json['maxParticipants'],
      isPublic: json['isPublic'] ?? false,
    );
  }
}

class MessageAttachment {
  final AttachmentType type;
  final String url;
  final String? filename;
  final int? size;
  final String? mimeType;
  final Map<String, dynamic>? metadata;

  MessageAttachment({
    required this.type,
    required this.url,
    this.filename,
    this.size,
    this.mimeType,
    this.metadata,
  });

  factory MessageAttachment.fromJson(Map<String, dynamic> json) {
    return MessageAttachment(
      type: _parseAttachmentType(json['type']),
      url: json['url'] ?? '',
      filename: json['filename'],
      size: json['size'],
      mimeType: json['mimeType'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': _attachmentTypeToString(type),
      'url': url,
      'filename': filename,
      'size': size,
      'mimeType': mimeType,
      'metadata': metadata,
    };
  }
}

enum AttachmentType {
  IMAGE,
  FILE,
  LOCATION,
}

AttachmentType _parseAttachmentType(dynamic value) {
  if (value == null) return AttachmentType.FILE;
  final str = value.toString().toLowerCase();
  switch (str) {
    case 'image':
      return AttachmentType.IMAGE;
    case 'file':
      return AttachmentType.FILE;
    case 'location':
      return AttachmentType.LOCATION;
    default:
      return AttachmentType.FILE;
  }
}

String _attachmentTypeToString(AttachmentType type) {
  switch (type) {
    case AttachmentType.IMAGE:
      return 'image';
    case AttachmentType.FILE:
      return 'file';
    case AttachmentType.LOCATION:
      return 'location';
  }
}

enum MessageType {
  TEXT,
  IMAGE,
  FILE,
  LOCATION,
  SYSTEM,
  ANNOUNCEMENT,
  POLL,
  EVENT,
}

enum ChatType {
  GROUP,
  PRIVATE,
}

enum ChatStatus {
  ACTIVE,
  INACTIVE,
  ARCHIVED,
  DELETED,
}

enum ChatRole {
  ADMIN,
  MODERATOR,
  MEMBER,
  GUEST,
}

enum MessageStatus {
  SENT,
  DELIVERED,
  READ,
  FAILED,
}

// Helper functions to parse enum values from backend (lowercase)
MessageType _parseMessageType(dynamic value) {
  if (value == null) return MessageType.TEXT;
  final str = value.toString().toLowerCase();
  switch (str) {
    case 'text':
      return MessageType.TEXT;
    case 'image':
      return MessageType.IMAGE;
    case 'file':
      return MessageType.FILE;
    case 'location':
      return MessageType.LOCATION;
    case 'system':
      return MessageType.SYSTEM;
    case 'announcement':
      return MessageType.ANNOUNCEMENT;
    case 'poll':
      return MessageType.POLL;
    case 'event':
      return MessageType.EVENT;
    default:
      return MessageType.TEXT;
  }
}

String _messageTypeToString(MessageType type) {
  switch (type) {
    case MessageType.TEXT:
      return 'text';
    case MessageType.IMAGE:
      return 'image';
    case MessageType.FILE:
      return 'file';
    case MessageType.LOCATION:
      return 'location';
    case MessageType.SYSTEM:
      return 'system';
    case MessageType.ANNOUNCEMENT:
      return 'announcement';
    case MessageType.POLL:
      return 'poll';
    case MessageType.EVENT:
      return 'event';
  }
}

MessageStatus _parseMessageStatus(dynamic value) {
  if (value == null) return MessageStatus.SENT;
  final str = value.toString().toLowerCase();
  switch (str) {
    case 'sent':
      return MessageStatus.SENT;
    case 'delivered':
      return MessageStatus.DELIVERED;
    case 'read':
      return MessageStatus.READ;
    case 'failed':
      return MessageStatus.FAILED;
    default:
      return MessageStatus.SENT;
  }
}

String _messageStatusToString(MessageStatus status) {
  switch (status) {
    case MessageStatus.SENT:
      return 'sent';
    case MessageStatus.DELIVERED:
      return 'delivered';
    case MessageStatus.READ:
      return 'read';
    case MessageStatus.FAILED:
      return 'failed';
  }
}

ChatType _parseChatType(dynamic value) {
  if (value == null) return ChatType.GROUP;
  final str = value.toString().toLowerCase();
  switch (str) {
    case 'group':
      return ChatType.GROUP;
    case 'private':
      return ChatType.PRIVATE;
    default:
      return ChatType.GROUP;
  }
}

ChatStatus _parseChatStatus(dynamic value) {
  if (value == null) return ChatStatus.ACTIVE;
  final str = value.toString().toLowerCase();
  switch (str) {
    case 'active':
      return ChatStatus.ACTIVE;
    case 'inactive':
      return ChatStatus.INACTIVE;
    case 'archived':
      return ChatStatus.ARCHIVED;
    case 'deleted':
      return ChatStatus.DELETED;
    default:
      return ChatStatus.ACTIVE;
  }
}

ChatRole _parseChatRole(dynamic value) {
  if (value == null) return ChatRole.MEMBER;
  final str = value.toString().toLowerCase();
  switch (str) {
    case 'admin':
      return ChatRole.ADMIN;
    case 'moderator':
      return ChatRole.MODERATOR;
    case 'member':
      return ChatRole.MEMBER;
    case 'guest':
      return ChatRole.GUEST;
    default:
      return ChatRole.MEMBER;
  }
}
