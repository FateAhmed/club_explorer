import 'dart:io';
import 'package:explorify/components/search_field.dart';
import 'package:explorify/components/tour_card.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/screens/home/home_controller.dart';
import 'package:explorify/screens/mainwrapper/main_wrapper_controller.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/cupertino.dart';

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
    final hasImage = imagePath.isNotEmpty && File(imagePath).existsSync();

    if (hasImage) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: FileImage(File(imagePath)),
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
                                authController.userName.isNotEmpty
                                    ? authController.userName
                                    : 'User',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textprimary,
                                ),
                              )),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
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
                        AppDimens.sizebox15,
                        Icon(
                          CupertinoIcons.list_bullet,
                          color: AppColors.grey,
                          size: 25,
                        ),
                      ],
                    ),
                  ],
                ),
                AppDimens.sizebox15,
                SearchField(
                  color: AppColors.white.withOpacity(0.1),
                  text: 'Search tours',
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
                AppDimens.sizebox15,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Tours',
                      style: TextStyle(
                        color: AppColors.textprimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Obx(
                  () => homeController.isLoading.value
                      ? SizedBox(
                          height: 350,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary1,
                            ),
                          ),
                        )
                      : homeController.allTours.isEmpty
                          ? SizedBox(
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
                          : SizedBox(
                              width: double.infinity,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ...homeController.allTours.map((tour) => TourCard(tour: tour)).toList(),
                                  ],
                                ),
                              ),
                            ),
                ),
                AppDimens.sizebox5,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Tour Bookings',
                      style:
                          TextStyle(color: AppColors.textprimary, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                AppDimens.sizebox20,
                Obx(
                  () => homeController.isLoading.value
                      ? Center(child: CircularProgressIndicator(color: AppColors.primary1))
                      : homeController.bookedTours.isEmpty
                          ? SizedBox(
                              height: 200,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.ticket,
                                      size: 48,
                                      color: AppColors.grey,
                                    ),
                                    AppDimens.sizebox10,
                                    Text(
                                      'No bookings found',
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
                          : Column(
                              children: homeController.bookedTours
                                  .map((tour) => TourCard(tour: tour, isBooked: true))
                                  .toList(),
                            ),
                ),
                AppDimens.sizebox20,
              ],
            ),
          )),
        ));
  }
}
