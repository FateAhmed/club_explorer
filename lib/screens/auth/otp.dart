import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/screens/auth/create_pass.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';

import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController otpController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hPadding20,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppDimens.sizebox20,
                IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    onPressed: () {
                      Get.back();
                    },
                    icon: Image.asset(
                      'assets/icons/arrow_back.png',
                      height: 28,
                      width: 28,
                    )),
                AppDimens.sizebox20,
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enter OTP',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textprimary,
                    ),
                  ),
                ),
                AppDimens.sizebox5,
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'We have just sent you 4 digit code via your email example@gmail.com',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textsecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                AppDimens.sizebox30,
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  controller: otpController,
                  cursorColor: AppColors.blue2,
                  autoDisposeControllers: false,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.none,
                  enableActiveFill: true,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(20),
                    fieldHeight: 60,
                    fieldWidth: 60,
                    inactiveColor: AppColors.grey200,
                    selectedColor: AppColors.blue2,
                    activeColor: AppColors.blue2,
                    inactiveFillColor: AppColors.grey200,
                    selectedFillColor: AppColors.grey200,
                    activeFillColor: AppColors.grey200,
                    borderWidth: 0.3,
                  ),
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  onChanged: (value) {
                    // handle value
                  },
                  onCompleted: (value) {
                    print("OTP completed: $value");
                    // You can trigger next action here
                  },
                ),
                AppDimens.sizebox20,
                ThemeButton(
                  text: 'Continue',
                  onpress: () {
                    Get.to(() => CreateNewPass());
                  },
                ),
                AppDimens.sizebox30,
                GestureDetector(
                  onTap: () {},
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Didn't recieve a code? ",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textsecondary.withOpacity(0.7)),
                        children: [
                          TextSpan(
                            text: 'Resend Code',
                            style: TextStyle(
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
        ),
      ),
    );
  }
}
