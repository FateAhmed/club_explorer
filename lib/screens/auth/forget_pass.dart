import 'package:explorify/components/theme_button.dart';
import 'package:explorify/components/theme_field.dart';
import 'package:explorify/controllers/auth_controller.dart';
import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:explorify/utils/Validations.dart';
import 'package:explorify/utils/Loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    authController.clearError();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!formKey.currentState!.validate()) return;

    LoadingDialog.show(context);

    final success = await authController.resetPassword(emailController.text.trim());

    if (mounted) {
      Navigator.pop(context); // Hide loading dialog

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Email Sent!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We have sent a password reset link to ${emailController.text.trim()}. Please check your email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textsecondary,
                  ),
                ),
              ],
            ),
            actions: [
              Center(
                child: ThemeButton(
                  width: 150,
                  hights: 45,
                  text: 'OK',
                  onpress: () {
                    Navigator.pop(context); // Close dialog
                    Get.back(); // Go back to login
                  },
                ),
              ),
            ],
          ),
        );
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
      body: SafeArea(
        child: Padding(
          padding: AppDimens.hPadding20,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppDimens.sizebox20,
                  IconButton(
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    onPressed: () => Get.back(),
                    icon: Image.asset(
                      'assets/icons/arrow_back.png',
                      height: 28,
                      width: 28,
                    ),
                  ),
                  AppDimens.sizebox20,
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Forgot Password',
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
                      'Enter your email to receive a password reset link',
                      style: TextStyle(fontSize: 14, color: AppColors.textsecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  AppDimens.sizebox30,

                  // Email Label
                  const Text(
                    'E-mail',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  AppDimens.sizebox10,

                  // Email TextField
                  CustomTextFormField(
                    title: 'Enter your email address',
                    controller: emailController,
                    focusNode: FocusNode(),
                    validator: (e) => validateEmail(e),
                  ),

                  AppDimens.sizebox40,

                  // Submit Button
                  Obx(() => ThemeButton(
                        text: authController.isLoading.value ? 'Sending...' : 'Send Reset Link',
                        onpress: authController.isLoading.value ? null : _handleResetPassword,
                      )),

                  AppDimens.sizebox20,

                  // Back to login
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Center(
                      child: Text(
                        'Back to Sign In',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
