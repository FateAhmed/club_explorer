import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:flutter/material.dart';

class SignInOptionsButton extends StatelessWidget {
  final String text;
  final VoidCallback? onpress;
  final double? hights;
  final Widget icon;
  const SignInOptionsButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onpress,
    this.hights,
  });
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 10;

    return ElevatedButton(
      onPressed: onpress,
      style: ElevatedButton.styleFrom(
          // backgroundColor: AppColors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.grey200),
              borderRadius: BorderRadius.circular(10))),
      child: Ink(
        decoration: BoxDecoration(
            color: AppColors.white, borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: double.infinity,
          height: hights ?? height * 0.7,
          alignment: Alignment.center,
          child: Row(
            children: [
              AppDimens.sizebox10,
              icon,
              AppDimens.sizebox35,
              Text(
                text,
                style: const TextStyle(
                    fontSize: 16, color: AppColors.textsecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
