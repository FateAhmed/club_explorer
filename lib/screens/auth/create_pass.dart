import 'package:club_explorer/components/dialogue.dart';
import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/components/theme_field.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:club_explorer/utils/Validations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateNewPass extends StatefulWidget {
  const CreateNewPass({super.key});

  @override
  State<CreateNewPass> createState() => _CreateNewPassState();
}

class _CreateNewPassState extends State<CreateNewPass> {
  TextEditingController passController = TextEditingController();
  TextEditingController cPassController = TextEditingController();

  bool isObsecure = false;
  bool isPassObsecure = false;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

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
                    'Create a \n New Password',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textprimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                AppDimens.sizebox10,

                Align(
                  alignment: Alignment.center,
                  child: Text(
                    'Enter your new password',
                    style:
                        TextStyle(fontSize: 14, color: AppColors.textsecondary),
                  ),
                ),
                AppDimens.sizebox35,
                Text(
                  'New password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                AppDimens.sizebox10,

                CustomTextFormField(
                  title: 'Enter your password',
                  controller: passController,
                  obscure: isPassObsecure,
                  suffixicon: IconButton(
                    icon: Icon(isPassObsecure
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        isPassObsecure = !isPassObsecure;
                      });
                    },
                  ),
                  focusNode: FocusNode(),
                  validator: (e) => validatePassword(e),
                ),

                AppDimens.sizebox25,

                // Password Label
                Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                AppDimens.sizebox10,

                CustomTextFormField(
                  controller: cPassController,
                  title: 'Confirm your password',
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

                AppDimens.sizebox50,

                ThemeButton(
                  text: 'Next',
                  onpress: () {
                    showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => ThemeDialogue(
                              dialogueWidth: width * 0.8,
                              icon: Image.asset('assets/icons/green_check.png'),
                              text1: 'Success',
                              text2: Text(
                                'Your password is succesfully \n created',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                              button2: ThemeButton(
                                  width: 160,
                                  hights: 65,
                                  text: 'Continue  ',
                                  onpress: () {}),
                            ));
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
