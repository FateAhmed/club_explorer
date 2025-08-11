import 'package:club_explorer/components/dialogue.dart';
import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/components/theme_field.dart';
import 'package:club_explorer/screens/auth/otp.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:club_explorer/utils/Validations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  TextEditingController cEmailController = TextEditingController();
  TextEditingController cPassController = TextEditingController();
  bool isChecked = false;
  bool isObsecure = false;

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
                    'Forget Password',
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
                    'Recover your account password',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textsecondary),
                  ),
                ),
                AppDimens.sizebox30,

                // Email Label
                Text(
                  'E-mail',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                AppDimens.sizebox10,

                // Email TextField (using your custom field)
                CustomTextFormField(
                  title: 'Enter your email address',
                  controller: cEmailController,
                  focusNode: FocusNode(),
                  validator: (e) => validateEmail(e),
                ),

                AppDimens.sizebox40,

                ThemeButton(
                  text: 'Next',
                  onpress: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => ThemeDialogue(
                              // icon: Image.asset('assets/icons/shield.png'),
                              text2: RichText(
                                text: TextSpan(
                                    text: 'I agree to the',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textsecondary,
                                      height: 1.4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Terms of Service ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textprimary,
                                          height: 1.4,
                                        ),
                                      ),
                                      TextSpan(text: 'and '),
                                      TextSpan(
                                        text: 'Conditions',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.textprimary,
                                          height: 1.4,
                                        ),
                                      ),
                                      TextSpan(
                                          text:
                                              ' of Use including consent to electronic communications and I affirm that the information provided is my own.')
                                    ]),
                                textAlign: TextAlign.center,
                              ),
                              button1: TextButton(
                                child: Text(
                                  'Disagree',
                                  style: TextStyle(color: AppColors.reddit),
                                ),
                                onPressed: () {},
                              ),
                              button2: ThemeButton(
                                  width: 150,
                                  hights: 50,
                                  text: 'Agree',
                                  onpress: () {
                                    Get.to(() => OtpScreen());
                                  }),
                            ));

                    // Future.delayed(const Duration(seconds: 2), () {});
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
