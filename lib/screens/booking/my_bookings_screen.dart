import 'package:explorify/controllers/chat_controller.dart';
import 'package:explorify/models/tour.dart';
import 'package:explorify/models/tour_booking.dart';
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
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  void _navigateToTourChat(TourModel tour) async {
    try {
      final chatController = Get.find<ChatController>();

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
          final bookings = homeController.tourBookings;

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
                final booking = bookings[index];
                final tour = homeController.tourMap[booking.tourId];

                // Get unread count for this tour's chat
                int unreadCount = 0;
                if (tour != null) {
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
                }
                return _buildBookingCard(context, booking, tour, unreadCount);
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBookingCard(BuildContext context, TourBookingModel booking, TourModel? tour, int unreadCount) {
    final days = tour?.itinerary?.length ?? 0;
    final dateFormat = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: () {
        if (tour != null) {
          Get.to(() => WebViewPage(url: WebRoutes.tourDetail(tour.id)));
        }
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
                    child: tour?.routeMapImage != null
                        ? Image.network(
                            tour!.routeMapImage!,
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
                        // Tour Title
                        Text(
                          tour?.title ?? 'Tour Booking',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textprimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Package name
                        Text(
                          booking.packageSelected,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary1,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Location
                        if (tour != null)
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
                                  '${tour.startLocation} → ${tour.endLocation}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.grey,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 8),
                        // Badges row
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            // Start date
                            if (booking.selectedStartDate != null)
                              _buildBadge(
                                icon: CupertinoIcons.calendar,
                                text: dateFormat.format(booking.selectedStartDate!),
                              ),
                            // Duration
                            if (days > 0)
                              _buildBadge(
                                icon: CupertinoIcons.time,
                                text: '$days ${days == 1 ? 'day' : 'days'}',
                              ),
                            // Riders
                            _buildBadge(
                              icon: CupertinoIcons.person_2,
                              text: '${booking.totalParticipants} rider${booking.totalParticipants != 1 ? 's' : ''}',
                            ),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _statusColor(booking.status).withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _statusIcon(booking.status),
                                    size: 12,
                                    color: _statusColor(booking.status),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking.status[0].toUpperCase() + booking.status.substring(1),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: _statusColor(booking.status),
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
            if (tour != null)
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

  Widget _buildBadge({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textprimary),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textprimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return CupertinoIcons.checkmark_circle_fill;
      case 'cancelled':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.clock_fill;
    }
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
