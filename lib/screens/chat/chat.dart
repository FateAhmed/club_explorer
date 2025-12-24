import 'dart:io';
import 'package:explorify/components/theme_field.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/utils/Validations.dart';
import 'package:explorify/controllers/chat_session_controller.dart';
import 'package:explorify/controllers/chat_controller.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/models/chat_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InChat extends StatefulWidget {
  final String chatId;
  final String chatName;

  const InChat({super.key, required this.chatId, required this.chatName});

  @override
  State<InChat> createState() => _InChatState();
}

class _InChatState extends State<InChat> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late ChatSessionController _sessionController;

  @override
  void initState() {
    super.initState();
    // Create session controller for this chat
    _sessionController = Get.createChatSession(
      chatId: widget.chatId,
      chatName: widget.chatName,
    );

    // Listen for text changes to send typing indicator
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    // Delete session controller when leaving
    Get.deleteChatSession(widget.chatId);
    super.dispose();
  }

  void _onTextChanged() {
    if (_textController.text.isNotEmpty) {
      _sessionController.onUserTyping();
    }
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      _sessionController.sendMessage(content: text);
      _textController.clear();

      // Scroll to bottom after sending message (with reverse: true, bottom is at 0)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: Container(
                  color: AppColors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          AppDimens.sizebox10,
                          Expanded(child: _buildMessageList()),
                          _buildInputField(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Debug overlay
          // const DebugOverlay(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary1,
                child: Text(
                  widget.chatName.isNotEmpty ? widget.chatName[0].toUpperCase() : 'C',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatName,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Obx(() {
                  final typingText = _sessionController.typingIndicatorText;
                  if (typingText != null) {
                    return Text(
                      typingText,
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    );
                  }
                  return Text(
                    "Online",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Only show participants icon for group chats
        if (_sessionController.currentChat?.isGroupChat == true)
          IconButton(
            icon: const Icon(Icons.people_outline),
            onPressed: _showParticipants,
            tooltip: 'View participants',
          ),
      ],
      backgroundColor: AppColors.white,
    );
  }

  void _showParticipants() {
    final participants = _sessionController.participants;
    final searchController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          // Filter participants based on search query
          final query = searchController.text.toLowerCase();
          final filteredParticipants = query.isEmpty
              ? participants
              : participants.where((p) {
                  final name = p.displayName.toLowerCase();
                  final email = (p.email ?? '').toLowerCase();
                  return name.contains(query) || email.contains(query);
                }).toList();

          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.people, color: AppColors.primary1),
                      const SizedBox(width: 8),
                      Text(
                        'Participants (${participants.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: searchController,
                    onChanged: (_) => setModalState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search participants...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear, color: Colors.grey[400]),
                              onPressed: () {
                                searchController.clear();
                                setModalState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),
                // Participants list
                Expanded(
                  child: filteredParticipants.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                query.isEmpty ? 'No participants found' : 'No results for "$query"',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredParticipants.length,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemBuilder: (context, index) {
                            final participant = filteredParticipants[index];
                            return _buildParticipantTile(participant);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildParticipantTile(ChatParticipant participant) {
    final authController = Get.find<AuthController>();
    final isCurrentUser = participant.userId == _sessionController.currentUserId;
    final roleColor = _getRoleColor(participant.role);
    final roleName = _getRoleName(participant.role);
    final displayName = isCurrentUser ? 'You' : participant.displayName;
    final avatarLetter = participant.name?.isNotEmpty == true
        ? participant.name![0].toUpperCase()
        : participant.email?.isNotEmpty == true
            ? participant.email![0].toUpperCase()
            : 'U';

    // Get profile image - URL for all users (from server)
    ImageProvider? avatarImage;
    if (isCurrentUser) {
      final profileImg = authController.userProfileImage;
      if (profileImg.isNotEmpty) {
        // Check if it's a URL or local file
        if (profileImg.startsWith('http')) {
          avatarImage = NetworkImage(profileImg);
        } else if (File(profileImg).existsSync()) {
          avatarImage = FileImage(File(profileImg));
        }
      }
    } else if (participant.hasProfileImage) {
      avatarImage = NetworkImage(participant.profileImage!);
    }

    return ListTile(
      onTap: isCurrentUser ? null : () => _showUserProfileDialog(participant, avatarImage),
      leading: CircleAvatar(
        backgroundColor: AppColors.primary1,
        backgroundImage: avatarImage,
        child: avatarImage == null
            ? Text(
                avatarLetter,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              displayName,
              style: TextStyle(
                fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: roleColor.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: roleColor, width: 1),
            ),
            child: Text(
              roleName,
              style: TextStyle(
                fontSize: 11,
                color: roleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        participant.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 12,
          color: participant.isActive ? Colors.green : Colors.grey,
        ),
      ),
    );
  }

  void _showUserProfileDialog(ChatParticipant participant, ImageProvider? avatarImage) {
    final avatarLetter = participant.name?.isNotEmpty == true
        ? participant.name![0].toUpperCase()
        : participant.email?.isNotEmpty == true
            ? participant.email![0].toUpperCase()
            : 'U';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // User avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary1,
              backgroundImage: avatarImage,
              child: avatarImage == null
                  ? Text(
                      avatarLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            // User name
            Text(
              participant.displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // User email if available
            if (participant.email != null && participant.email!.isNotEmpty)
              Text(
                participant.email!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(height: 8),
            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: participant.isActive ? Colors.green : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  participant.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 14,
                    color: participant.isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Send DM button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _startPrivateChat(participant),
                icon: const Icon(Icons.message, color: Colors.white),
                label: const Text(
                  'Send Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary1,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _startPrivateChat(ChatParticipant participant) async {
    // Store necessary data before closing modals
    final targetUserId = participant.userId;
    final targetDisplayName = participant.displayName;

    // Close both modals first
    Navigator.of(context).pop(); // Close user profile dialog
    Navigator.of(context).pop(); // Close participants modal

    // Wait for modals to close
    await Future.delayed(const Duration(milliseconds: 200));

    // Show loading snackbar instead of dialog to avoid widget tree issues
    Get.snackbar(
      'Please wait',
      'Starting conversation...',
      snackPosition: SnackPosition.BOTTOM,
      showProgressIndicator: true,
      isDismissible: false,
      duration: const Duration(seconds: 30),
    );

    try {
      final chatController = Get.find<ChatController>();
      final chat = await chatController.createPrivateChat(targetUserId);

      // Close the snackbar
      Get.closeAllSnackbars();

      if (chat != null && chat.id != null) {
        // Wait for frame to complete before navigating
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Go back to messages screen first
          Get.back();

          // Then navigate to new chat after a short delay
          Future.delayed(const Duration(milliseconds: 150), () {
            chatController.setCurrentChat(chat);
            Get.to(
              () => InChat(
                chatId: chat.id!,
                chatName: targetDisplayName,
              ),
            );
          });
        });
      } else {
        Get.snackbar(
          'Error',
          'Failed to start conversation',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[100],
          colorText: Colors.red[800],
        );
      }
    } catch (e) {
      Get.closeAllSnackbars();
      Get.snackbar(
        'Error',
        'Failed to start conversation: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[800],
      );
    }
  }

  Color _getRoleColor(ChatRole role) {
    switch (role) {
      case ChatRole.ADMIN:
        return Colors.red;
      case ChatRole.MODERATOR:
        return Colors.orange;
      case ChatRole.MEMBER:
        return Colors.blue;
      case ChatRole.GUEST:
        return Colors.grey;
    }
  }

  String _getRoleName(ChatRole role) {
    switch (role) {
      case ChatRole.ADMIN:
        return 'Admin';
      case ChatRole.MODERATOR:
        return 'Moderator';
      case ChatRole.MEMBER:
        return 'Member';
      case ChatRole.GUEST:
        return 'Guest';
    }
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (_sessionController.isLoading && _sessionController.messages.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.primary1,
          ),
        );
      }

      if (_sessionController.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.grey,
              ),
              AppDimens.sizebox10,
              Text(
                'No messages yet',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppDimens.sizebox5,
              Text(
                'Start the conversation!',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: _scrollController,
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        itemCount: _sessionController.messages.length,
        itemBuilder: (context, index) {
          final message = _sessionController.messages[index];
          return _buildMessageBubble(message);
        },
      );
    });
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isSent = _sessionController.isOwnMessage(message);

    if (message.isDeleted) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'This message was deleted',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (isSent) {
      return _buildSentMessage(message);
    } else {
      return _buildReceivedMessage(message);
    }
  }

  Widget _buildSentMessage(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            decoration: BoxDecoration(
              color: message.isLocalOnly ? const Color(0xFFD6B45D).withOpacity(0.7) : const Color(0xFFD6B45D),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.content,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Show sending indicator for local-only messages
              if (message.isLocalOnly) ...[
                SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              // Show failed indicator
              if (message.status == MessageStatus.FAILED) ...[
                Icon(Icons.error_outline, size: 12, color: Colors.red),
                const SizedBox(width: 4),
                Text(
                  'Failed',
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                _sessionController.formatMessageTime(message.createdAt),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
              if (message.isEdited) ...[
                const SizedBox(width: 4),
                Text(
                  'edited',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          AppDimens.sizebox15,
        ],
      ),
    );
  }

  Widget _buildReceivedMessage(ChatMessage message) {
    // Find participant to get their profile image
    final participant = _sessionController.participants.firstWhereOrNull(
      (p) => p.userId == message.senderId,
    );
    final senderInitial =
        (message.senderName ?? 'U').isNotEmpty ? (message.senderName ?? 'U')[0].toUpperCase() : 'U';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.primary1,
          backgroundImage:
              participant?.hasProfileImage == true ? NetworkImage(participant!.profileImage!) : null,
          child: participant?.hasProfileImage != true
              ? Text(
                  senderInitial,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.65,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(message.content),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sessionController.formatMessageTime(message.createdAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                if (message.isEdited) ...[
                  const SizedBox(width: 4),
                  Text(
                    'edited',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInputField() {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            controller: _textController,
            title: 'Write a message',
            radius: 40,
            prefixicon: 'assets/icons/paperclip.png',
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (_) => _sendMessage(),
            suffixicon: Obx(() {
              return GestureDetector(
                onTap: _sessionController.isSendingMessage ? null : _sendMessage,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0, 1, 3, 1),
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: _sessionController.isSendingMessage ? Colors.grey : AppColors.primary1,
                    shape: BoxShape.circle,
                  ),
                  child: _sessionController.isSendingMessage
                      ? Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      : Image.asset('assets/icons/send.png'),
                ),
              );
            }),
            focusNode: FocusNode(),
            validator: (e) => notEmpty(e),
          ),
        ),
      ],
    );
  }
}
