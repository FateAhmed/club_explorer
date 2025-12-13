import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:flutter/material.dart';

class ThemeButton extends StatelessWidget {
  final String text;
  final VoidCallback? onpress;
  final double? hights;
  final double? width;

  final Color? color;
  final Color? textColor;
  final String? icon;
  final double? iconHeight;
  final double? iconWidth;
  final double? fontsize;
  final FontWeight? fontWeight;
  const ThemeButton({
    super.key,
    required this.text,
    required this.onpress,
    this.icon,
    this.color,
    this.fontsize,
    this.iconHeight,
    this.width,
    this.fontWeight,
    this.iconWidth,
    this.textColor,
    this.hights,
  });
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 10;

    return ElevatedButton(
      onPressed: onpress,
      style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.transparent,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          )),
      child: Ink(
        decoration: BoxDecoration(color: AppColors.primary1, borderRadius: BorderRadius.circular(10)),
        child: Container(
          width: width ?? double.infinity,
          height: hights ?? height * 0.7,
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary1)),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  fontSize: fontsize ?? 18,
                  fontWeight: fontWeight ?? FontWeight.bold,
                  color: textColor ?? AppColors.textprimary,
                ),
              ),
              if (icon != null)
                Padding(
                  padding: AppDimens.hPadding5,
                  child: Image.asset(
                    icon!,
                    height: iconHeight ?? 20,
                    width: iconWidth ?? 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
