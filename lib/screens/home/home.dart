import 'package:club_explorer/components/search_field.dart';
import 'package:club_explorer/components/tour_card.dart';
import 'package:club_explorer/screens/home/home_controller.dart';
import 'package:club_explorer/screens/tour/tour_route.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController homeController = Get.put(HomeController());

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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage('assets/icons/sample-user.png'),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Matr Kohler',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textprimary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.grey400),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/icons/notification.png',
                              height: 28,
                              width: 28,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        AppDimens.sizebox15,
                        Icon(
                          Icons.menu,
                          size: 30,
                        ),
                      ],
                    ),
                  ],
                ),
                AppDimens.sizebox20,
                SearchField(
                  color: AppColors.white.withOpacity(0.1),
                  text: 'Search tours, destinations...',
                  onpress: () {},
                  preicon: Image.asset(
                    'assets/icons/search.png',
                    height: 30,
                    width: 30,
                  ),
                  posticon: Image.asset(
                    'assets/icons/filter.png',
                    height: 30,
                    width: 30,
                  ),
                ),
                AppDimens.sizebox30,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Tours',
                      style:
                          TextStyle(color: AppColors.textprimary, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primary1,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
                AppDimens.sizebox10,
                Obx(() => homeController.isLoading.value
                    ? SizedBox(
                        height: 350,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary1,
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 400,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: homeController.allTours.length,
                          padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: TourCard(tour: homeController.allTours[index]),
                            );
                          },
                        ),
                      )),
                AppDimens.sizebox30,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Tour Bookings',
                      style:
                          TextStyle(color: AppColors.textprimary, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                AppDimens.sizebox10,
                Obx(() => homeController.isLoading.value
                    ? SizedBox(
                        height: 350,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary1,
                          ),
                        ),
                      )
                    : !homeController.isLoading.value && homeController.bookedTours.isEmpty
                        ? SizedBox(height: 100, child: Center(child: Text('No bookings found')))
                        : SizedBox(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: homeController.bookedTours.length,
                              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 12),
                                  child: TourCard(
                                    tour: homeController.bookedTours[index],
                                    isBooked: true,
                                  ),
                                );
                              },
                            ),
                          )),
                AppDimens.sizebox20,
              ],
            ),
          )),
        ));
  }
}
