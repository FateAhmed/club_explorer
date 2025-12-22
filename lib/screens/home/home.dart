import 'dart:io';
import 'package:explorify/components/horizontal_booking_card.dart';
import 'package:explorify/components/tour_card.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/screens/booking/my_bookings_screen.dart';
import 'package:explorify/screens/chat/chat.dart';
import 'package:explorify/screens/home/home_controller.dart';
import 'package:explorify/screens/mainwrapper/main_wrapper_controller.dart';
import 'package:explorify/screens/notifications/notifications_screen.dart';
import 'package:explorify/screens/search/search_screen.dart';
import 'package:explorify/services/chat_service.dart';
import 'package:explorify/controllers/chat_controller.dart';
import 'package:explorify/models/tour.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController homeController = Get.put(HomeController());
  final AuthController authController = Get.find<AuthController>();

  String _getInitials() {
    final name = authController.userName;
    if (name.isEmpty) return 'U';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  void _goToProfile() {
    final mainWrapperController = Get.find<MainWrapperController>();
    mainWrapperController.goToTab(2); // Profile is at index 2
  }

  Widget _buildAvatar() {
    final imagePath = authController.userProfileImage;
    ImageProvider? avatarImage;

    if (imagePath.isNotEmpty) {
      // Check if it's a URL (from server) or local file path
      if (imagePath.startsWith('http')) {
        avatarImage = NetworkImage(imagePath);
      } else if (File(imagePath).existsSync()) {
        avatarImage = FileImage(File(imagePath));
      }
    }

    if (avatarImage != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: avatarImage,
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary1,
      child: Text(
        _getInitials(),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _navigateToTourChat(TourModel tour) async {
    try {
      // Show loading indicator
      Get.dialog(
        Center(
          child: CircularProgressIndicator(color: AppColors.primary1),
        ),
        barrierDismissible: false,
      );

      // Get chat for this tour
      final chatService = ChatService(authToken: authController.token);
      final chat = await chatService.getChatByTourId(tour.id);

      // Close loading dialog
      Get.back();

      // Get or create ChatController and set current chat
      final chatController = Get.put(ChatController());
      chatController.setCurrentChat(chat);

      // Navigate to chat
      Get.to(() => InChat(
            chatId: chat.id!,
            chatName: chat.name,
          ));
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to load chat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withAlpha(200),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white.withAlpha(10),
        body: SafeArea(
          child: SingleChildScrollView(
              child: Padding(
            padding: AppDimens.hPadding20,
            child: Column(
              children: [
                AppDimens.sizebox20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _goToProfile,
                      child: Row(
                        children: [
                          Obx(() => _buildAvatar()),
                          AppDimens.sizebox10,
                          Obx(() => Text(
                                authController.userName.isNotEmpty ? authController.userName : 'User',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textprimary,
                                ),
                              )),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.to(() => const NotificationsScreen()),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey400),
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(5),
                        child: Center(
                          child: Icon(
                            CupertinoIcons.bell,
                            color: AppColors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppDimens.sizebox15,
                GestureDetector(
                  onTap: () => Get.to(() => const SearchScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.grey300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(CupertinoIcons.search, color: AppColors.grey, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search tours...',
                            style: TextStyle(
                              color: AppColors.grey,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          height: 24,
                          width: 1,
                          color: AppColors.grey300,
                          margin: const EdgeInsets.only(right: 12),
                        ),
                        Icon(CupertinoIcons.slider_horizontal_3, color: AppColors.grey, size: 20),
                      ],
                    ),
                  ),
                ),
                AppDimens.sizebox15,
                // Conditional layout based on booking status
                Obx(() {
                  final hasBookings = homeController.bookedTours.isNotEmpty;
                  final isLoading = homeController.isLoading.value;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bookings section (only if user has bookings)
                      if (hasBookings) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Bookings',
                              style: TextStyle(
                                color: AppColors.textprimary,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Get.to(() => const MyBookingsScreen());
                              },
                              child: Text(
                                'See All',
                                style: TextStyle(
                                  color: AppColors.primary1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AppDimens.sizebox10,
                        // Horizontal scroll of booking cards - reactive to unread counts
                        SizedBox(
                          height: 190,
                          child: Builder(
                            builder: (context) {
                              // Check ChatController availability at build time
                              if (!Get.isRegistered<ChatController>()) {
                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: homeController.bookedTours.length,
                                  itemBuilder: (context, index) {
                                    final tour = homeController.bookedTours[index];
                                    return HorizontalBookingCard(
                                      tour: tour,
                                      status: 'Confirmed',
                                      onChatPressed: () => _navigateToTourChat(tour),
                                      unreadCount: 0,
                                    );
                                  },
                                );
                              }
                              final chatController = Get.find<ChatController>();
                              return Obx(() {
                                // Observe unread counts map to trigger rebuilds
                                final _ = chatController.unreadCountsMap.length;

                                return ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: homeController.bookedTours.length,
                                  itemBuilder: (context, index) {
                                    final tour = homeController.bookedTours[index];
                                    // Get unread count for this tour's chat
                                    int unreadCount = 0;
                                    final tourChat = chatController.groupChats.firstWhereOrNull(
                                      (chat) => chat.tourId == tour.id,
                                    );
                                    if (tourChat != null && tourChat.id != null) {
                                      unreadCount = chatController.getUnreadCount(tourChat.id!);
                                    }
                                    return HorizontalBookingCard(
                                      tour: tour,
                                      status: 'Confirmed',
                                      onChatPressed: () => _navigateToTourChat(tour),
                                      unreadCount: unreadCount,
                                    );
                                  },
                                );
                              });
                            },
                          ),
                        ),
                        AppDimens.sizebox20,
                      ],

                      // All Tours section header
                      Text(
                        'All Tours',
                        style: TextStyle(
                          color: AppColors.textprimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppDimens.sizebox10,

                      // Tours content (loading, empty, or list)
                      if (isLoading)
                        SizedBox(
                          height: 350,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary1,
                            ),
                          ),
                        )
                      else if (homeController.allTours.isEmpty)
                        SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  CupertinoIcons.map,
                                  size: 48,
                                  color: AppColors.grey,
                                ),
                                AppDimens.sizebox10,
                                Text(
                                  'No tours available',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        // Vertical list of tour cards
                        ...homeController.allTours
                            .map((tour) => TourCard(tour: tour, isHorizontal: true))
                            .toList(),
                    ],
                  );
                }),
                AppDimens.sizebox20,
              ],
            ),
          )),
        ));
  }
}
