import 'package:explorify/components/theme_field.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/utils/Validations.dart';
import 'package:explorify/controllers/chat_controller.dart';
import 'package:explorify/models/chat_models.dart';
import 'package:explorify/widgets/debug_overlay.dart';
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
  final TextEditingController chatController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late ChatController chatController_;

  @override
  void initState() {
    super.initState();
    chatController_ = Get.find<ChatController>();

    // Load messages for this chat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController_.loadMessages(widget.chatId);
      chatController_.markMessagesAsRead(widget.chatId);
    });
  }

  @override
  void dispose() {
    chatController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isNotEmpty) {
      chatController_.sendMessage(
        chatId: widget.chatId,
        content: text,
        messageType: MessageType.TEXT,
      );
      chatController.clear();

      // Scroll to bottom after sending message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
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
              AppBar(
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chatName,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        Obx(() {
                          final typingUsers = chatController_.typingUsers;
                          if (typingUsers.isNotEmpty) {
                            return Text(
                              "${typingUsers.keys.join(', ')} is typing...",
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
                    )
                  ],
                ),
                backgroundColor: AppColors.white,
              ),
              Expanded(
                child: Container(
                  color: AppColors.white,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          AppDimens.sizebox10,
                          Expanded(
                            child: Obx(() {
                              if (chatController_.isLoading && chatController_.messages.isEmpty) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary1,
                                  ),
                                );
                              }

                              if (chatController_.messages.isEmpty) {
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
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                itemCount: chatController_.messages.length,
                                itemBuilder: (context, index) {
                                  final message = chatController_.messages[index];
                                  final isSent =
                                      message.senderId == 'current_user'; // Replace with actual user ID check

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
                                    return Align(
                                      alignment: Alignment.centerRight,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            margin: const EdgeInsets.only(bottom: 8),
                                            constraints: BoxConstraints(
                                                maxWidth: MediaQuery.of(context).size.width * 0.65),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFD6B45D),
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
                                              Text(
                                                chatController_.formatMessageTime(message.createdAt),
                                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                              ),
                                              if (message.isEdited) ...[
                                                const SizedBox(width: 4),
                                                Text(
                                                  'edited',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey,
                                                      fontStyle: FontStyle.italic),
                                                ),
                                              ],
                                            ],
                                          ),
                                          AppDimens.sizebox15
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.primary1,
                                          child: Text(
                                            message.senderId.isNotEmpty
                                                ? message.senderId[0].toUpperCase()
                                                : 'U',
                                            style: TextStyle(
                                              color: AppColors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              margin: const EdgeInsets.only(bottom: 8),
                                              constraints: BoxConstraints(
                                                  maxWidth: MediaQuery.of(context).size.width * 0.65),
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
                                                  chatController_.formatMessageTime(message.createdAt),
                                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                                ),
                                                if (message.isEdited) ...[
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'edited',
                                                    style: const TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                        fontStyle: FontStyle.italic),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }
                                },
                              );
                            }),
                          ),

                          // Input Field
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextFormField(
                                  controller: chatController,
                                  title: 'Write a message',
                                  radius: 40,
                                  prefixicon: 'assets/icons/paperclip.png',
                                  suffixicon: Obx(() {
                                    return GestureDetector(
                                      onTap: chatController_.isSendingMessage ? null : sendMessage,
                                      child: Container(
                                        margin: const EdgeInsets.fromLTRB(0, 1, 3, 1),
                                        height: 48,
                                        width: 48,
                                        decoration: BoxDecoration(
                                          color: chatController_.isSendingMessage
                                              ? Colors.grey
                                              : AppColors.primary1,
                                          shape: BoxShape.circle,
                                        ),
                                        child: chatController_.isSendingMessage
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  color: AppColors.white,
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : Image.asset('assets/icons/send.png'),
                                      ),
                                    );
                                  }),
                                  onTap: sendMessage,
                                  focusNode: FocusNode(),
                                  validator: (e) => notEmpty(e),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Debug overlay
          const DebugOverlay(),
        ],
      ),
    );
  }
}
