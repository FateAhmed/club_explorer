import 'package:explorify/config/routes.dart';
import 'package:explorify/models/tour.dart';
import 'package:explorify/screens/home/web_widget/web_widget.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingCard extends StatelessWidget {
  final TourModel tour;
  final String? status;
  final DateTime? bookingDate;

  const BookingCard({
    super.key,
    required this.tour,
    this.status = 'Confirmed',
    this.bookingDate,
  });

  Color _getStatusColor() {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.success;
    }
  }

  IconData _getStatusIcon() {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return CupertinoIcons.checkmark_circle_fill;
      case 'pending':
        return CupertinoIcons.clock_fill;
      case 'cancelled':
        return CupertinoIcons.xmark_circle_fill;
      default:
        return CupertinoIcons.checkmark_circle_fill;
    }
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    final days = tour.itinerary?.length ?? 0;
    final price = tour.packages?.isNotEmpty == true ? tour.packages!.first.price : 0;

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
          children: [
            // Main content row
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
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
                  ),
                  const SizedBox(width: 12),
                  // Tour details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          tour.title,
                          style: const TextStyle(
                            fontSize: 16,
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
                              size: 14,
                              color: AppColors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                tour.startLocation,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Duration and Price row
                        Row(
                          children: [
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
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textprimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$$price',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary1,
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
            // Bottom row with status and actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(),
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status ?? 'Confirmed',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Booking date or View button
                  Row(
                    children: [
                      if (bookingDate != null) ...[
                        Icon(
                          CupertinoIcons.time,
                          size: 14,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(bookingDate!),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary1,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              CupertinoIcons.arrow_right,
                              size: 12,
                              color: Colors.white,
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
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        CupertinoIcons.photo,
        color: AppColors.grey,
        size: 32,
      ),
    );
  }
}
