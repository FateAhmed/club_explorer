import 'package:explorify/components/theme_button.dart';
import 'package:explorify/screens/mainwrapper/mainwrapper.dart';
import 'package:explorify/utils/Loader.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:explorify/components/theme_field.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/utils/Validations.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();
  bool isObsecure = true;
  bool isConfirmObsecure = true;

  @override
  void initState() {
    super.initState();
    authController.clearError();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!formKey.currentState!.validate()) return;

    // Check if passwords match
    if (passController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    LoadingDialog.show(context);

    final success = await authController.register(
      email: emailController.text.trim(),
      password: passController.text,
      name: nameController.text.trim(),
    );

    if (mounted) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: Padding(
            padding: AppDimens.horizontalPadding16,
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Create Account',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ),
                    AppDimens.sizebox30,

                    // Full Name
                    const Text(
                      'Full Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    AppDimens.sizebox10,
                    CustomTextFormField(
                      title: 'Enter your name',
                      controller: nameController,
                      focusNode: FocusNode(),
                      validator: (e) => validateName(e),
                    ),
                    AppDimens.sizebox25,

                    // Email
                    const Text(
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
                      controller: emailController,
                      focusNode: FocusNode(),
                      validator: (e) => validateEmail(e),
                    ),
                    AppDimens.sizebox25,

                    // Password
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    AppDimens.sizebox10,
                    CustomTextFormField(
                      controller: passController,
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
                    AppDimens.sizebox25,

                    // Confirm Password
                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    AppDimens.sizebox10,
                    CustomTextFormField(
                      controller: confirmPassController,
                      title: 'Confirm your password',
                      obscure: isConfirmObsecure,
                      suffixicon: IconButton(
                        icon: Icon(isConfirmObsecure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isConfirmObsecure = !isConfirmObsecure;
                          });
                        },
                      ),
                      focusNode: FocusNode(),
                      validator: (e) {
                        if (e == null || e.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (e != passController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    AppDimens.sizebox15,

                    // Terms and Conditions
                    RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(
                        text: "By signing up you agree to our ",
                        style: TextStyle(fontSize: 13, color: AppColors.grey),
                        children: [
                          TextSpan(
                            text: 'Terms ',
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
                    AppDimens.sizebox15,

                    // Sign Up Button
                    Obx(() => ThemeButton(
                          text: authController.isLoading.value ? 'Creating Account...' : 'Create An Account',
                          onpress: authController.isLoading.value ? null : _handleSignup,
                        )),

                    AppDimens.sizebox20,

                    // Login Link
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Center(
                        child: RichText(
                          text: TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textsecondary.withValues(alpha: 0.7),
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign In',
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
