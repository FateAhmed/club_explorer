import 'package:explorify/utils/AppColors.dart';
import 'package:flutter/material.dart';

class HotelCard extends StatelessWidget {
  final Map<String, String> place;

  const HotelCard({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.fromLTRB(0, 8, 10, 8),
      elevation: 2,
      child: Container(
        width: width * 0.65,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      place['image']!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Rating badge
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary2.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.star, color: AppColors.grey300, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          place['rating']!,
                          style: const TextStyle(
                              color: AppColors.white, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 20,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(Icons.favorite_border,
                          color: AppColors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and features
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place['name']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Image.asset(
                              'assets/icons/Bed.png',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 4),
                            Text('${place['bedrooms']} bedrooms',
                                style: TextStyle(
                                    fontSize: 14, color: AppColors.primary2)),
                            const SizedBox(width: 8),
                            Image.asset(
                              'assets/icons/area.png',
                              height: 20,
                              width: 20,
                            ),
                            const SizedBox(width: 4),
                            Text('${place['area']}m²',
                                style: TextStyle(
                                    fontSize: 14, color: AppColors.primary2)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${place['price']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary2,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'per month',
                        style: TextStyle(fontSize: 10, color: AppColors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
