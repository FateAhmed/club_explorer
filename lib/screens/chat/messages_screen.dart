import 'package:explorify/components/search_field.dart';
import 'package:explorify/screens/chat/chat.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/controllers/chat_controller.dart';
import 'package:explorify/widgets/debug_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatController chatController = Get.put(ChatController());

    // Load chats when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.loadUserChats();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        centerTitle: true,
        backgroundColor: AppColors.grey50,
      ),
      backgroundColor: AppColors.grey50,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AppDimens.sizebox10,
                  SearchField(
                    color: AppColors.white.withOpacity(0.1),
                    text: 'Search chats',
                    onpress: () {},
                    preicon: Icon(
                      CupertinoIcons.search,
                      color: AppColors.grey,
                    ),
                    posticon: Icon(
                      CupertinoIcons.slider_horizontal_3,
                      color: AppColors.grey,
                    ),
                  ),
                  AppDimens.sizebox10,
                  Expanded(
                    child: Obx(() {
                      if (chatController.isLoading) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary1,
                          ),
                        );
                      }

                      if (chatController.chats.isEmpty) {
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
                                'No chats yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              AppDimens.sizebox5,
                              Text(
                                'Start a conversation by booking a tour',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        itemCount: chatController.chats.length,
                        separatorBuilder: (context, index) => const Divider(
                          thickness: 0.5,
                        ),
                        itemBuilder: (context, index) {
                          final chat = chatController.chats[index];
                          final lastMessage = chat.lastMessage;
                          final unreadCount = chatController.getUnreadCount(chat.id!);

                          return ListTile(
                            onTap: () {
                              chatController.setCurrentChat(chat);
                              Get.to(() => InChat(
                                    chatId: chat.id!,
                                    chatName: chat.name,
                                  ));
                            },
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                            leading: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primary1,
                              child: Text(
                                chat.name.isNotEmpty ? chat.name[0].toUpperCase() : 'C',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    chat.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  chatController.formatMessageTime(chat.lastActivity),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            subtitle: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lastMessage?.content ?? 'No messages yet',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    margin: const EdgeInsets.only(left: 8),
                                    decoration: const BoxDecoration(
                                      color: AppColors.notification,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      "$unreadCount",
                                      style: const TextStyle(color: Colors.white, fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          // Debug overlay - only show in debug mode
          if (kDebugMode) const DebugOverlay(),
        ],
      ),
    );
  }
}
