import 'package:club_explorer/screens/mainwrapper/main_wrapper_controller.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final MainWrapperController _mainWrapperController = Get.find<MainWrapperController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: PageView(
          controller: _mainWrapperController.pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: _mainWrapperController.animateToTab,
          children: [..._mainWrapperController.pages],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: SizedBox(
          height: 70,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _bottomAppBarItem(
                    icon: 'assets/icons/home_b.png',
                    page: 0,
                    context,
                    label: "Home",
                  ),
                  // _bottomAppBarItem(
                  //   icon: 'assets/icons/bike_b.png',
                  //   page: 1,
                  //   context,
                  //   label: "Rental",
                  // ),
                  // _bottomAppBarItem(
                  //   icon: 'assets/icons/map_b.png',
                  //   page: 2,
                  //   context,
                  //   label: "Tours",
                  // ),
                  // _bottomAppBarItem(
                  //   icon: 'assets/icons/bed_b.png',
                  //   page: 3,
                  //   context,
                  //   label: "Hotels",
                  // ),
                  _bottomAppBarItem(
                    icon: 'assets/icons/chat_b.png',
                    page: 1,
                    context,
                    label: "Message",
                  ),
                  _bottomAppBarItem(
                    icon: 'assets/icons/user.png',
                    page: 2,
                    context,
                    label: "Profile",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomAppBarItem(BuildContext context, {required icon, required page, required label}) {
    return ZoomTapAnimation(
      onTap: () => _mainWrapperController.goToTab(page),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              '$icon',
              color: _mainWrapperController.currentPage == page ? AppColors.primary1 : Colors.grey,
              height: 25,
              width: 25,
            ),
            Text(
              label,
              style: TextStyle(
                  color: _mainWrapperController.currentPage == page ? AppColors.primary1 : Colors.grey,
                  fontSize: 13,
                  fontWeight: _mainWrapperController.currentPage == page ? FontWeight.w600 : null),
            ),
          ],
        ),
      ),
    );
  }
}
