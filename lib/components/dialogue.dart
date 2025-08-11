import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeDialogue extends StatelessWidget {
  final VoidCallback? onpress;
  final Widget? icon;
  final String? text1;
  final Widget? text2;
  final Widget? button1;
  final Widget? button2;
  final double? dialogueWidth;
  const ThemeDialogue(
      {super.key,
      this.onpress,
      this.icon,
      this.text1,
      this.text2,
      this.dialogueWidth,
      this.button1,
      this.button2});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        width: dialogueWidth ?? width * 0.8,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AppDimens.sizebox10,
            if (icon != null) AppDimens.sizebox40,

            if (icon != null) SizedBox(width: 80, height: 80, child: icon),
            if (icon != null) AppDimens.sizebox20,

            Text(
              text1 ?? '',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: AppColors.textprimary,
              ),
              textAlign: TextAlign.center,
            ),

            if (text1 != null) AppDimens.sizebox8,

            // Description

            text2 ?? Container(),

            AppDimens.sizebox15,

            // Confirm button
            if (button1 != null || button2 != null)
              Row(
                mainAxisAlignment: (button1 != null && button2 != null)
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.center,
                children: [button1 ?? SizedBox(), button2!],
              ),
            if (button1 != null || button2 != null) AppDimens.sizebox50,
          ],
        ),
      ),
    );
  }
}
