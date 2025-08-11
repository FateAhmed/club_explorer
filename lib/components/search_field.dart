import 'package:club_explorer/utils/AppColors.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String text;
  final VoidCallback? onpress;
  final Image? posticon;
  final Image? preicon;
  final double? height;
  final BorderSide? border;
  final BorderRadius? radius;

  final double? dynamicwidth;
  final double? postIconPadding;
  final Color? color;

  const SearchField({
    super.key,
    required this.text,
    this.height,
    this.color,
    this.radius,
    this.border,
    this.postIconPadding,
    this.dynamicwidth,
    required this.onpress,
    this.posticon,
    this.preicon,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: text,
        hintStyle:
            TextStyle(color: AppColors.grey, fontWeight: FontWeight.bold),
        prefixIcon: preicon != null
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: preicon,
              )
            : null,
        suffixIcon: GestureDetector(
          onTap: onpress,
          child: Padding(
            padding: EdgeInsets.all(postIconPadding ?? 4.0),
            child: Row(
              mainAxisSize:
                  MainAxisSize.min, // ✅ Prevents row from taking full width
              children: [
                Container(
                  height: 24, // Match TextField height
                  width: 1,
                  color: AppColors.grey,
                  margin: EdgeInsets.only(
                      right: 4), // Space between divider and icon
                ),
                posticon ?? SizedBox(), // Your actual icon widget
              ],
            ),
          ),
        ),
        filled: true,
        fillColor: color ?? AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(25),
          borderSide:
              BorderSide(color: AppColors.grey400), // ✅ Your custom color
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(25),
          borderSide: BorderSide(
              color: AppColors.grey, width: 2), // Optional bold focus
        ),
        border: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(25),
          borderSide: BorderSide(color: AppColors.grey400),
        ),
      ),
    );
  }
}
