import 'dart:io';
import 'package:explorify/components/theme_button.dart';
import 'package:explorify/config/routes.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/screens/auth/login.dart';
import 'package:explorify/screens/booking/my_bookings_screen.dart';
import 'package:explorify/screens/home/web_widget/web_widget.dart';
import 'package:explorify/screens/profile/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  Widget _buildAvatar() {
    final imagePath = authController.userProfileImage;
    ImageProvider? avatarImage;

    if (imagePath.isNotEmpty) {
      // Check if it's a URL (from server) or local file path
      if (imagePath.startsWith('http')) {
        avatarImage = NetworkImage(imagePath);
      } else if (File(imagePath).existsSync()) {
        avatarImage = FileImage(File(imagePath));
      }
    }

    if (avatarImage != null) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: avatarImage,
      );
    }

    return CircleAvatar(
      radius: 50,
      backgroundColor: AppColors.primary1,
      child: Text(
        _getInitials(),
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Profile'),
        centerTitle: true,
      ),
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDimens.hPadding20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: AppDimens.padding20,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Obx(() => _buildAvatar()),
                      AppDimens.sizebox20,
                      Obx(() => Text(
                            authController.userName.isNotEmpty ? authController.userName : 'User',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textprimary,
                            ),
                          )),
                      AppDimens.sizebox5,
                      Obx(() => Text(
                            authController.userEmail,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textsecondary,
                            ),
                          )),
                      AppDimens.sizebox20,
                      ThemeButton(
                        text: 'Edit Profile',
                        onpress: () {
                          Get.to(() => const EditProfileScreen());
                        },
                        color: AppColors.primary1,
                        textColor: AppColors.white,
                        hights: 45,
                        fontsize: 16,
                      ),
                    ],
                  ),
                ),
                AppDimens.sizebox30,
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textprimary,
                  ),
                ),
                AppDimens.sizebox15,
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.lock_outline,
                        title: 'Privacy & Security',
                        subtitle: 'Manage your privacy settings',
                        onTap: () {
                          Get.to(() => WebViewPage(
                            url: WebRoutes.privacyPolicy(),
                            title: 'Privacy Policy',
                          ));
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                        onTap: () {
                          Get.to(() => WebViewPage(
                            url: WebRoutes.helpSupport(),
                            title: 'Help & Support',
                          ));
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App version and information',
                        onTap: () {
                          Get.to(() => WebViewPage(
                            url: WebRoutes.about(),
                            title: 'About',
                          ));
                        },
                      ),
                    ],
                  ),
                ),
                AppDimens.sizebox30,
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textprimary,
                  ),
                ),
                AppDimens.sizebox15,
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(
                        icon: Icons.person_outline,
                        title: 'Personal Information',
                        subtitle: 'Update your personal details',
                        onTap: () {
                          Get.to(() => const EditProfileScreen());
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        subtitle: 'Manage your payment options',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This feature is coming soon'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.history,
                        title: 'Booking History',
                        subtitle: 'View your past bookings',
                        onTap: () {
                          Get.to(() => const MyBookingsScreen());
                        },
                      ),
                    ],
                  ),
                ),
                AppDimens.sizebox30,
                ThemeButton(
                  text: 'Logout',
                  onpress: () {
                    _showLogoutDialog();
                  },
                  color: AppColors.error,
                  textColor: AppColors.white,
                  hights: 50,
                  fontsize: 16,
                  fontWeight: FontWeight.bold,
                ),
                AppDimens.sizebox10,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: AppDimens.padding20,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary1.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary1,
                size: 24,
              ),
            ),
            AppDimens.sizebox15,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textprimary,
                    ),
                  ),
                  AppDimens.sizebox5,
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textsecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.grey400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        color: AppColors.grey200,
        height: 1,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textprimary,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textsecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.textsecondary,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    await authController.logout();
    Get.offAll(() => const Login());
  }
}
