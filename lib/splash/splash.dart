import 'dart:async';

import 'package:club_explorer/splash/desc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    // Navigate to SignIn after 3 seconds
    Timer(const Duration(seconds: 3), () {
      Get.off(() => SplashDetail());
    });
    return Container(
      decoration: BoxDecoration(
        color: Color(0XFF252525),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo_new.png',
          height: double.infinity,
          width: width * 0.8,
        ),
      ),
    );
  }
}
