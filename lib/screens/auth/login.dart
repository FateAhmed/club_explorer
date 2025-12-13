import 'package:explorify/components/theme_button.dart';
import 'package:explorify/utils/Loader.dart';
import 'package:explorify/screens/mainwrapper/mainwrapper.dart';
import 'package:explorify/screens/auth/forget_pass.dart';
import 'package:explorify/screens/auth/signup.dart';
import 'package:get/get.dart';
import 'package:explorify/components/theme_field.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/utils/Validations.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:flutter/material.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController cEmailController = TextEditingController();
  TextEditingController cPassController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isChecked = false;
  bool isObsecure = true;
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // Clear any previous error messages
    authController.clearError();
  }

  @override
  void dispose() {
    cEmailController.dispose();
    cPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: AppDimens.padding20,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppDimens.sizebox10,
                    Center(
                      child: Text(
                        "Lets Sign you in",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    AppDimens.sizebox10,
                    AppDimens.sizebox30,

                    Text(
                      'Email Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    AppDimens.sizebox10,

                    CustomTextFormField(
                      title: 'Enter your email address',
                      controller: cEmailController,
                      focusNode: FocusNode(),
                      validator: (e) => validateEmail(e),
                    ),

                    AppDimens.sizebox20,
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
                        icon: Icon(isObsecure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isObsecure = !isObsecure;
                          });
                        },
                      ),
                      focusNode: FocusNode(),
                      validator: (e) => validatePassword(e),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Row(
                        //   children: [
                        //     CheckBoxRounded(
                        //       onTap: (value) {
                        //         setState(() {
                        //           isChecked = value!;
                        //         });
                        //       },
                        //       checkedColor: AppColors.primary1,
                        //     ),
                        //     AppDimens.sizebox5,
                        //     Text(
                        //       'Remember Me',
                        //       style: TextStyle(
                        //         fontSize: 14,
                        //         color: AppColors.grey,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        Spacer(),
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
                    Obx(() => ThemeButton(
                          text: authController.isLoading.value ? 'Signing In...' : 'Sign In',
                          onpress: () async {
                            if (formKey.currentState!.validate()) {
                              LoadingDialog.show(context);

                              final success = await authController.login(
                                cEmailController.text.trim(),
                                cPassController.text,
                              );

                              if (context.mounted) {
                                Navigator.pop(context); // Hide loading dialog

                                if (success) {
                                  Get.offAll(() => MainWrapper());
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(authController.errorMessage.value),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            }
                          },
                        )),

                    AppDimens.sizebox20,
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
                              color: AppColors.textsecondary.withOpacity(0.7),
                            ),
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

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   children: [
                    //     Container(
                    //       color: AppColors.grey400,
                    //       width: 80,
                    //       height: 1,
                    //       margin: EdgeInsets.only(right: 20),
                    //     ),
                    //     Text(
                    //       'Or Sign In with',
                    //       style: TextStyle(color: AppColors.grey, fontSize: 16),
                    //     ),
                    //     Container(
                    //       color: AppColors.grey400,
                    //       width: 80,
                    //       height: 1,
                    //       margin: EdgeInsets.only(left: 20),
                    //     ),
                    //   ],
                    // ),
                    // AppDimens.sizebox40,
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //   children: [
                    //     Container(
                    //       height: 60,
                    //       width: 80,
                    //       decoration: BoxDecoration(
                    //         color: AppColors.grey100.withOpacity(0.8),
                    //         borderRadius: BorderRadius.circular(15),
                    //       ),
                    //       child: Center(
                    //         child: Image.asset(
                    //           'assets/icons/google.png',
                    //           height: 30,
                    //           width: 30,
                    //           fit: BoxFit.contain, // or BoxFit.fill for force scaling
                    //         ),
                    //       ),
                    //     ),
                    //     Container(
                    //       height: 60,
                    //       width: 80,
                    //       decoration: BoxDecoration(
                    //         color: AppColors.grey100.withOpacity(0.8),
                    //         borderRadius: BorderRadius.circular(15),
                    //       ),
                    //       child: Center(
                    //         child: Image.asset(
                    //           'assets/icons/apple.png',
                    //           height: 30,
                    //           width: 30,
                    //           fit: BoxFit.contain, // or BoxFit.fill for force scaling
                    //         ),
                    //       ),
                    //     ),
                    //     Container(
                    //       height: 60,
                    //       width: 80,
                    //       decoration: BoxDecoration(
                    //         color: AppColors.grey100.withOpacity(0.8),
                    //         borderRadius: BorderRadius.circular(15),
                    //       ),
                    //       child: Center(
                    //         child: Image.asset(
                    //           'assets/icons/fb.png',
                    //           height: 30,
                    //           width: 30,
                    //           fit: BoxFit.contain, // or BoxFit.fill for force scaling
                    //         ),
                    //       ),
                    //     )
                    //   ],
                    // ),
                    // AppDimens.sizebox40,
                    // Center(
                    //   child: RichText(
                    //     textAlign: TextAlign.center,
                    //     text: TextSpan(
                    //       text: "By signing up you agree to our ",
                    //       style: TextStyle(fontSize: 16, color: AppColors.grey),
                    //       children: [
                    //         TextSpan(
                    //           text: 'Terms \n',
                    //           style: TextStyle(
                    //             color: AppColors.textprimary,
                    //           ),
                    //         ),
                    //         TextSpan(
                    //           text: 'and ',
                    //           style: TextStyle(
                    //             color: AppColors.grey,
                    //           ),
                    //         ),
                    //         TextSpan(
                    //           text: 'Conditions of Use',
                    //           style: TextStyle(
                    //             color: AppColors.textprimary,
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
