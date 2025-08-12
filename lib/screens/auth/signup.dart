import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/screens/mainwrapper/mainwrapper.dart';
import 'package:get/get.dart';
import 'package:club_explorer/components/theme_field.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:club_explorer/utils/Validations.dart';
import 'package:flutter/material.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isObsecure = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
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
                    Center(
                      child:
                          Text('Create Account', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    ),
                    AppDimens.sizebox30,
                    Text(
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
                      controller: emailController,
                      focusNode: FocusNode(),
                      validator: (e) => validateEmail(e),
                    ),
                    AppDimens.sizebox25,
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
                    AppDimens.sizebox15,
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
                    ThemeButton(
                      text: 'Create An Account',
                      onpress: () {
                        if (formKey.currentState!.validate()) {
                          Get.offAll(() => MainWrapper());
                        }
                      },
                    ),
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
