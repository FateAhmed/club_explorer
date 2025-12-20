import 'package:explorify/controllers/chat_controller.dart';
import 'package:explorify/models/tour.dart';
import 'package:explorify/screens/chat/chat.dart';
import 'package:explorify/screens/home/home_controller.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:explorify/config/routes.dart';
import 'package:explorify/screens/home/web_widget/web_widget.dart';
import 'package:explorify/screens/tour/navigation_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  void _navigateToTourChat(TourModel tour) async {
    try {
      final chatController = Get.find<ChatController>();

      // Find the chat for this tour
      final tourChat = chatController.groupChats.firstWhereOrNull(
        (chat) => chat.tourId == tour.id,
      );

      if (tourChat != null && tourChat.id != null) {
        chatController.setCurrentChat(tourChat);
        Get.to(() => InChat(
              chatId: tourChat.id!,
              chatName: tourChat.name,
            ));
      } else {
        Get.snackbar(
          'Chat Not Available',
          'The group chat for this tour is not available yet',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open chat',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        backgroundColor: AppColors.grey50,
      ),
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Obx(() {
          final bookings = homeController.bookedTours;

          // Only show loading if no cached data
          if (homeController.isLoading.value && bookings.isEmpty) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary1,
              ),
            );
          }

          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: AppColors.grey,
                  ),
                  AppDimens.sizebox10,
                  Text(
                    'No bookings yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AppDimens.sizebox5,
                  Text(
                    'Book a tour to see it here',
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

          return RefreshIndicator(
            onRefresh: () async {
              await homeController.getBookedTours();
            },
            color: AppColors.primary1,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final tour = bookings[index];
                // Get unread count for this tour's chat
                int unreadCount = 0;
                try {
                  final chatController = Get.find<ChatController>();
                  final tourChat = chatController.groupChats.firstWhereOrNull(
                    (chat) => chat.tourId == tour.id,
                  );
                  if (tourChat != null && tourChat.id != null) {
                    unreadCount = chatController.getUnreadCount(tourChat.id!);
                  }
                } catch (e) {
                  // ChatController not initialized yet
                }
                return _buildBookingCard(context, tour, unreadCount);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, TourModel tour, int unreadCount) {
    final days = tour.itinerary?.length ?? 0;

    return GestureDetector(
      onTap: () {
        Get.to(() => WebViewPage(url: WebRoutes.tourDetail(tour.id)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section: Image + Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tour image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: tour.routeMapImage != null
                        ? Image.network(
                            tour.routeMapImage!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  // Tour info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          tour.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textprimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Location
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.location_solid,
                              size: 12,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tour.startLocation,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Duration badge + Status badge row
                        Row(
                          children: [
                            // Duration badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.grey100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar,
                                    size: 12,
                                    color: AppColors.textprimary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$days ${days == 1 ? 'day' : 'days'}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textprimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    CupertinoIcons.checkmark_circle_fill,
                                    size: 12,
                                    color: AppColors.success,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Confirmed',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              height: 1,
              color: AppColors.grey100,
            ),
            // Bottom section: Action buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  // Navigation button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final tourPoints = tour.tourPoints ?? [];
                        if (tourPoints.isEmpty) {
                          Get.snackbar(
                            'No Route',
                            'No navigation points available for this tour',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        final routePoints = tourPoints
                            .map((p) => maps.LatLng(p.lat, p.lng))
                            .toList();
                        final pointNames = tourPoints.map((p) => p.name).toList();
                        Get.to(() => NavigationScreen(
                              routePoints: routePoints,
                              pointNames: pointNames,
                              tourName: tour.title,
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary1,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.location_fill,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Navigation',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Chat button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _navigateToTourChat(tour),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.primary1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  CupertinoIcons.chat_bubble_fill,
                                  size: 16,
                                  color: AppColors.primary1,
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                      child: Text(
                                        unreadCount > 9 ? '9+' : '$unreadCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Group Chat',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 90,
      height: 90,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        CupertinoIcons.photo,
        color: AppColors.grey,
        size: 28,
      ),
    );
  }
}
