import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/models/tour.dart';
import 'package:club_explorer/screens/home/web_widget/web_widget.dart';
import 'package:club_explorer/screens/tour/tour_route.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TourCard extends StatelessWidget {
  final TourModel tour;
  final bool isBooked;

  const TourCard({super.key, required this.tour, this.isBooked = false});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        Get.to(() => WebViewPage(url: 'https://app-club-explorer.ahmadt.com/tour/tour-detail/${tour.id}'));
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.fromLTRB(0, 8, 10, 8),
        elevation: 1,
        child: Container(
          width: width * 0.8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    margin: const EdgeInsets.all(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(tour.routeMapImage, fit: BoxFit.cover),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, color: AppColors.primary1, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '${tour.itinerary.length} days',
                            style: TextStyle(
                                color: AppColors.textprimary, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Favorite button
                  // Positioned(
                  //   top: 20,
                  //   right: 20,
                  //   child: Container(
                  //     padding: const EdgeInsets.all(8),
                  //     decoration: const BoxDecoration(
                  //       color: Colors.white,
                  //       shape: BoxShape.circle,
                  //     ),
                  //     child: const Icon(
                  //       Icons.favorite_border,
                  //       color: AppColors.primary1,
                  //       size: 20,
                  //     ),
                  //   ),
                  // ),
                ],
              ),

              // Info section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      tour.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.textprimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Location
                    // Row(
                    //   children: [
                    //     Icon(Icons.location_on, color: AppColors.grey, size: 18),
                    //     const SizedBox(width: 4),
                    //     Expanded(
                    //       child: Text(
                    //         '${tour.startLocation} to ${tour.endLocation}',
                    //         style: TextStyle(
                    //           fontSize: 14,
                    //           color: AppColors.grey,
                    //           fontWeight: FontWeight.w400,
                    //         ),
                    //         overflow: TextOverflow.ellipsis,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 12),

                    // Features and price row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Days and weather info
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              color: AppColors.grey,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${tour.itinerary.length} days',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tour.temperatureRange,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),

                        // Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '\$${tour.packages.isNotEmpty ? tour.packages.first.price : '299'}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary1,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'per person',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (isBooked) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: Text(
                          'Booked',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],

                    if (!isBooked) ...[
                      const SizedBox(height: 12),
                      ThemeButton(
                        hights: 40,
                        text: 'View Tour Route',
                        onpress: () {
                          Get.to(() => TourRouteScreen(
                                tourId: tour.id,
                                tourName: tour.title,
                                tourDuration: '${tour.itinerary.length} days',
                                tourDistance: '${tour.packages.first.price} km',
                                tourDescription:
                                    'An epic adventure exploring the wonders surrounding Las Vegas, from the man-made marvel of Hoover Dam to the fiery landscapes of Valley of Fire, the cool peaks of Mount Charleston, and the extreme beauty of Death Valley.',
                                routePoints: tour.tourPoints.map((e) => LatLng(e.lat, e.lng)).toList(),
                                pointNames: tour.tourPoints.map((e) => e.name).toList(),
                              ));
                        },
                      ),
                      AppDimens.sizebox10,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
