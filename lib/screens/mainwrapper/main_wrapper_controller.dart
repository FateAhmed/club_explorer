import 'package:explorify/screens/chat/messages_screen.dart';
import 'package:explorify/screens/home/home.dart';
import 'package:explorify/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainWrapperController extends GetxController {
  late PageController pageController;

  RxInt currentPage = 0.obs;
  RxBool isDarkTheme = false.obs;

  List<Widget> pages = [
    HomePage(),
    // WebViewPage(
    //   url: 'https://app-club-explorer.ahmadt.com/vehicle/e9f5ae24-e358-4d12-a5fc-6ec9604b7141',
    // ),
    // WebViewPage(
    //   url: 'https://app-club-explorer.ahmadt.com/tour',
    // ),
    // WebViewPage(
    //   url: 'https://app-club-explorer.ahmadt.com/hotels?region=2008',
    // ),
    MessagesScreen(),
    ProfileScreen(),
  ];

  ThemeMode get theme => Get.isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void switchTheme(ThemeMode mode) {
    Get.changeThemeMode(mode);
  }

  void goToTab(int page) {
    currentPage.value = page;
    pageController.jumpToPage(page);
  }

  void animateToTab(int page) {
    currentPage.value = page;
    pageController.animateToPage(page, duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  @override
  void onInit() {
    pageController = PageController(initialPage: 0);
    super.onInit();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
