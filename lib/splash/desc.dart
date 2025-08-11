import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/screens/auth/login.dart';
import 'package:club_explorer/screens/auth/signup.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';

class SplashDetail extends StatefulWidget {
  const SplashDetail({super.key});

  @override
  State<SplashDetail> createState() => _SplashDetailState();
}

class _SplashDetailState extends State<SplashDetail> {
  int currentIndex = 0;

  final CarouselSliderController carouselController =
      CarouselSliderController();

  final List<Map<String, String>> carouselData = [
    {
      "image": "assets/images/bg_1.jpg",
      "title": "Luxury and Comfort,\nJust a Tap Away",
      "subtitle":
          "Semper in cursus magna et eu varius \n nunc adipiscing. Elementum justo, laoreet \n id sem.",
    },
    {
      "image": "assets/images/bg_2.jpg",
      "title": "Book with Ease, Stay with Style",
      "subtitle":
          "Semper in cursus magna et eu varius \n nunc adipiscing. Elementum justo, laoreet \n id sem.",
    },
    {
      "image": "assets/images/bg_3.jpg",
      "title": "Discover Your Dream Hotel, Effortlessly",
      "subtitle":
          "Semper in cursus magna et eu varius \n nunc adipiscing. Elementum justo, laoreet \n id sem.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Stack(
          children: [
            CarouselSlider.builder(
              itemCount: carouselData.length,
              carouselController: carouselController,
              itemBuilder: (context, index, realIndex) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(carouselData[index]["image"]!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 40),
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            carouselData[index]["title"]!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            carouselData[index]["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.grey200,
                            ),
                          ),
                        ),
                        AppDimens.sizebox150
                      ],
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),

            // Page Indicator
            if (currentIndex != carouselData.length - 1)
              Positioned(
                bottom: 170,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    carouselData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentIndex == index ? 30 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: currentIndex == index
                            ? AppColors.primary1
                            : AppColors.grey300,
                      ),
                    ),
                  ),
                ),
              ),

            // Continue / Get Started button
            Positioned(
              bottom: 80,
              left: 24,
              right: 24,
              child: ThemeButton(
                text: currentIndex == carouselData.length - 1
                    ? 'Get Started'
                    : 'Continue',
                onpress: () {
                  if (currentIndex == carouselData.length - 1) {
                    Get.to(() => Login());
                  } else {
                    carouselController.nextPage();
                  }
                },
              ),
            ),

            // RichText for registration
            if (currentIndex == carouselData.length - 1)
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => Get.to(() => CreateAccount()),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "Don't have an account? ",
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.white,
                      ),
                      children: [
                        TextSpan(
                          text: 'Register',
                          style: const TextStyle(
                            color: AppColors.primary1,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
