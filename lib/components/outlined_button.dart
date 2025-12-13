import 'package:explorify/utils/AppColors.dart';
import 'package:flutter/material.dart';

class OutlinedThemeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onpress;
  final double? hights;
  const OutlinedThemeButton({
    super.key,
    required this.text,
    required this.onpress,
    this.hights,
  });
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 10;

    return ElevatedButton(
      onPressed: onpress,
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.primary2),
              borderRadius: BorderRadius.circular(10))),
      child: Ink(
        decoration: BoxDecoration(
            color: AppColors.white,
            // gradient: LinearGradient(
            //   colors: [AppColors.primary1, AppColors.primary2],
            //   begin: Alignment.topCenter,
            //   end: Alignment.bottomCenter,
            // ),

            borderRadius: BorderRadius.circular(15)),
        child: Container(
          width: double.infinity,
          height: hights ?? height * 0.7,
          alignment: Alignment.center,
          child: Text(
            text,
            style: const TextStyle(fontSize: 18, color: AppColors.primary2),
          ),
        ),
      ),
    );
  }
}
