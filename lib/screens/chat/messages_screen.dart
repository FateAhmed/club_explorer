import 'package:explorify/components/search_field.dart';
import 'package:explorify/screens/chat/chat.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/controllers/chat_controller.dart';
import 'package:explorify/models/chat_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ChatController chatController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    chatController = Get.put(ChatController());

    // Load all chats when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      chatController.loadUserChats();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        backgroundColor: AppColors.grey50,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary1,
          labelColor: AppColors.primary1,
          unselectedLabelColor: AppColors.grey,
          tabs: [
            Obx(() => _buildTabWithBadge('Group Chats', false)),
            Obx(() => _buildTabWithBadge('Private Chats', true)),
          ],
        ),
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
                    color: AppColors.white.withValues(alpha: 0.1),
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
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Group Chats Tab
                        _buildChatList(isGroupChat: true),
                        // Direct Messages Tab
                        _buildChatList(isGroupChat: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Debug overlay - only show in debug mode
          // if (kDebugMode) const DebugOverlay(),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String title, bool isPrivate) {
    // Access the RxMap to trigger reactivity
    final _ = chatController.unreadCountsMap.length;
    final unreadCount = isPrivate
        ? chatController.privateChatsUnreadCount
        : chatController.groupChatsUnreadCount;

    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title),
          if (unreadCount > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.notification,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                unreadCount > 99 ? '99+' : '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChatList({required bool isGroupChat}) {
    return Obx(() {
      final chats = isGroupChat ? chatController.groupChats : chatController.privateChats;

      // Only show loading if we have no cached data
      if (chatController.isLoading && chats.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: AppColors.primary1,
          ),
        );
      }

      if (chats.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isGroupChat ? Icons.group_outlined : Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.grey,
              ),
              AppDimens.sizebox10,
              Text(
                isGroupChat ? 'No group chats yet' : 'No direct messages yet',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              AppDimens.sizebox5,
              Text(
                isGroupChat ? 'Book a tour to join group chats' : 'Start a conversation with other travelers',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.only(top: 10, bottom: 10),
        itemCount: chats.length,
        separatorBuilder: (context, index) => const Divider(
          thickness: 0.5,
        ),
        itemBuilder: (context, index) {
          final chat = chats[index];
          return _buildChatTile(chat, isGroupChat);
        },
      );
    });
  }

  Widget _buildChatTile(Chat chat, bool isGroupChat) {
    final lastMessage = chat.lastMessage;

    return ListTile(
      onTap: () {
        chatController.setCurrentChat(chat);
        Get.to(() => InChat(
              chatId: chat.id!,
              chatName: chat.name,
            ));
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: isGroupChat ? AppColors.primary1 : Colors.blue,
            child: isGroupChat
                ? const Icon(Icons.group, color: Colors.white, size: 24)
                : Text(
                    chat.name.isNotEmpty ? chat.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
          ),
          if (!isGroupChat)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chat.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                if (isGroupChat && chat.startDate != null)
                  Text(
                    'Departure: ${DateFormat('MMM d, yyyy').format(chat.startDate!)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary1,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chatController.formatMessageTime(chat.lastActivity),
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          if (isGroupChat)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                Icons.people_outline,
                size: 14,
                color: Colors.grey,
              ),
            ),
          Expanded(
            child: Text(
              lastMessage?.content ?? 'No messages yet',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Wrap unread badge in Obx for reactive updates
          Obx(() {
            final unreadCount = chatController.getUnreadCount(chat.id!);
            if (unreadCount > 0) {
              return Container(
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
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
