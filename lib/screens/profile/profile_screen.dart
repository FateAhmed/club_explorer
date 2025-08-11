import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white.withOpacity(0.1),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: AppDimens.hPadding20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDimens.sizebox20,
                // Header with back button and title
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Get.back(),
                      icon: Image.asset(
                        'assets/icons/arrow_back.png',
                        height: 28,
                        width: 28,
                      ),
                    ),
                    AppDimens.sizebox15,
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textprimary,
                      ),
                    ),
                  ],
                ),
                AppDimens.sizebox30,

                // Profile Header Section
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
                      // Profile Picture
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage('assets/icons/sample-user.png'),
                      ),
                      AppDimens.sizebox20,

                      // User Name
                      Text(
                        'Matr Kohler',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textprimary,
                        ),
                      ),
                      AppDimens.sizebox5,

                      // User Email
                      Text(
                        'matr.kohler@example.com',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textsecondary,
                        ),
                      ),
                      AppDimens.sizebox20,

                      // Edit Profile Button
                      ThemeButton(
                        text: 'Edit Profile',
                        onpress: () {
                          // TODO: Navigate to edit profile screen
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

                // Settings Section
                Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textprimary,
                  ),
                ),
                AppDimens.sizebox15,

                // Settings Options
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
                          // TODO: Navigate to privacy settings
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'Get help and contact support',
                        onTap: () {
                          // TODO: Navigate to help screen
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App version and information',
                        onTap: () {
                          // TODO: Navigate to about screen
                        },
                      ),
                    ],
                  ),
                ),
                AppDimens.sizebox30,

                // Account Section
                Text(
                  'Account',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textprimary,
                  ),
                ),
                AppDimens.sizebox15,

                // Account Options
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
                          // TODO: Navigate to personal info screen
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        subtitle: 'Manage your payment options',
                        onTap: () {
                          // TODO: Navigate to payment methods
                        },
                      ),
                      _buildDivider(),
                      _buildSettingsItem(
                        icon: Icons.history,
                        title: 'Booking History',
                        subtitle: 'View your past bookings',
                        onTap: () {
                          // TODO: Navigate to booking history
                        },
                      ),
                    ],
                  ),
                ),
                AppDimens.sizebox40,

                // Logout Button
                ThemeButton(
                  text: 'Logout',
                  onpress: () {
                    _showLogoutDialog();
                  },
                  color: AppColors.error,
                  textColor: AppColors.white,
                  hights: 50,
                  fontsize: 16,
                  bold: true,
                ),
                AppDimens.sizebox20,
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

  void _logout() {
    // TODO: Implement logout logic
    // This should clear user data, tokens, etc.
    // For now, we'll just navigate to login screen
    Get.offAllNamed('/login'); // Assuming you have a login route
  }
}
