import 'package:explorify/splash/desc.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/screens/mainwrapper/mainwrapper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Minimum splash display time
    await Future.delayed(const Duration(seconds: 2));

    // Wait for auth initialization to complete
    while (!_authController.isInitialized.value) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Navigate based on auth state
    if (_authController.isLoggedIn) {
      Get.offAll(() => MainWrapper());
    } else {
      Get.off(() => SplashDetail());
    }
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0XFF252525),
      ),
      child: Center(
        child: Image.asset(
          'assets/icons/icon.png',
          height: double.infinity,
          width: width * 0.8,
        ),
      ),
    );
  }
}
