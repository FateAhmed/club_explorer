import 'package:club_explorer/components/dialogue.dart';
import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/screens/mainwrapper/mainwrapper.dart';
import 'package:club_explorer/screens/auth/forget_pass.dart';
import 'package:club_explorer/screens/auth/signup.dart';
import 'package:club_explorer/screens/home/home.dart';
import 'package:get/get.dart';
import 'package:club_explorer/components/theme_field.dart';
import 'package:flutter_check_box_rounded/flutter_check_box_rounded.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:club_explorer/utils/Validations.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
                    'Let’s Sign you in',
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
                    'Lorem ipsum dolor sit amet, consectetur',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textsecondary),
                  ),
                ),
                AppDimens.sizebox30,

                // Email Label
                Text(
                  'Email Address',
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

                AppDimens.sizebox25,

                // Password Label
                Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                AppDimens.sizebox10,

                CustomTextFormField(
                  controller: cPassController,
                  title: 'Enter your password',
                  obscure: isObsecure,
                  suffixicon: IconButton(
                    icon: Icon(
                        isObsecure ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        isObsecure = !isObsecure;
                      });
                    },
                  ),
                  focusNode: FocusNode(),
                  validator: (e) => validatePassword(e),
                ),

                AppDimens.sizebox15,

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CheckBoxRounded(
                          onTap: (value) {
                            setState(() {
                              isChecked = value!;
                            });
                          },
                          checkedColor: AppColors.primary1,
                        ),
                        AppDimens.sizebox5,
                        Text(
                          'Remember Me',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Get.to(() => ForgetPass());
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.reddit,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                AppDimens.sizebox20,

                ThemeButton(
                  text: 'Sign In',
                  onpress: () {
                    Get.to(() => MainWrapper());
                  },
                ),

                AppDimens.sizebox30,
                GestureDetector(
                  onTap: () {
                    Get.to(() => CreateAccount());
                  },
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textsecondary.withOpacity(0.7)),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
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
                AppDimens.sizebox30,

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: AppColors.grey400,
                      width: 80,
                      height: 1,
                      margin: EdgeInsets.only(right: 20),
                    ),
                    Text(
                      'Or Sign In with',
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                    Container(
                      color: AppColors.grey400,
                      width: 80,
                      height: 1,
                      margin: EdgeInsets.only(left: 20),
                    ),
                  ],
                ),
                AppDimens.sizebox40,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 60,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.grey100.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/google.png',
                          height: 30,
                          width: 30,
                          fit: BoxFit
                              .contain, // or BoxFit.fill for force scaling
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.grey100.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/apple.png',
                          height: 30,
                          width: 30,
                          fit: BoxFit
                              .contain, // or BoxFit.fill for force scaling
                        ),
                      ),
                    ),
                    Container(
                      height: 60,
                      width: 80,
                      decoration: BoxDecoration(
                        color: AppColors.grey100.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/fb.png',
                          height: 30,
                          width: 30,
                          fit: BoxFit
                              .contain, // or BoxFit.fill for force scaling
                        ),
                      ),
                    )
                  ],
                ),
                AppDimens.sizebox40,
                Center(
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "By signing up you agree to our ",
                      style: TextStyle(fontSize: 16, color: AppColors.grey),
                      children: [
                        TextSpan(
                          text: 'Terms \n',
                          style: TextStyle(
                            color: AppColors.textprimary,
                          ),
                        ),
                        TextSpan(
                          text: 'and ',
                          style: TextStyle(
                            color: AppColors.grey,
                          ),
                        ),
                        TextSpan(
                          text: 'Conditions of Use',
                          style: TextStyle(
                            color: AppColors.textprimary,
                          ),
                        ),
                      ],
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
