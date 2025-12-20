import 'package:explorify/screens/mainwrapper/main_wrapper_controller.dart';
import 'package:explorify/controllers/chat_controller.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:flutter/cupertino.dart';

class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final MainWrapperController _mainWrapperController = Get.find<MainWrapperController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey100,
      body: PageView(
        controller: _mainWrapperController.pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: _mainWrapperController.animateToTab,
        children: [..._mainWrapperController.pages],
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 12,
          bottom: MediaQuery.of(context).padding.bottom > 0 ? 20 : 8,
        ),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _bottomAppBarItem(
                icon: Icon(
                  CupertinoIcons.home,
                  color: _mainWrapperController.currentPage == 0 ? AppColors.primary1 : Colors.grey,
                  size: 22,
                ),
                page: 0,
                context,
                label: "Home",
              ),
              _bottomAppBarItem(
                icon: _buildChatIconWithBadge(),
                page: 1,
                context,
                label: "Chats",
              ),
              _bottomAppBarItem(
                icon: Icon(
                  CupertinoIcons.person,
                  color: _mainWrapperController.currentPage == 2 ? AppColors.primary1 : Colors.grey,
                  size: 22,
                ),
                page: 2,
                context,
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatIconWithBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          CupertinoIcons.chat_bubble_text,
          color: _mainWrapperController.currentPage == 1 ? AppColors.primary1 : Colors.grey,
          size: 22,
        ),
        if (Get.isRegistered<ChatController>())
          GetX<ChatController>(
            builder: (controller) {
              final count = controller.totalUnreadCount;
              if (count > 0) {
                return Positioned(
                  right: -8,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
      ],
    );
  }

  Widget _bottomAppBarItem(BuildContext context, {required Widget icon, required page, required label}) {
    return ZoomTapAnimation(
      onTap: () => _mainWrapperController.goToTab(page),
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: _mainWrapperController.currentPage == page ? AppColors.primary1 : Colors.grey,
                fontSize: 11,
                fontWeight: _mainWrapperController.currentPage == page ? FontWeight.w600 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
