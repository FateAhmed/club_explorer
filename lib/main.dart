import 'package:explorify/splash/splash.dart';
import 'package:explorify/screens/mainwrapper/main_wrapper_controller.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize controllers
  Get.put(AuthController(), permanent: true);
  Get.put(MainWrapperController());

  // Initialize NotificationService (will setup FCM)
  await Get.putAsync(() => NotificationService().init(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Explorify',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
