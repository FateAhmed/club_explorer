import 'package:explorify/utils/AppColors.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String text;
  final VoidCallback? onpress;
  final Widget? posticon;
  final Widget? preicon;
  final double? height;
  final BorderSide? border;
  final BorderRadius? radius;

  final double? dynamicwidth;
  final double? postIconPadding;
  final Color? color;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

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
    this.controller,
    this.onChanged,
    this.onClear,
  });
  @override
  Widget build(BuildContext context) {
    final hasText = controller?.text.isNotEmpty ?? false;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: text,
        hintStyle: TextStyle(color: AppColors.grey, fontWeight: FontWeight.w500),
        prefixIcon: preicon != null
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: preicon,
              )
            : null,
        suffixIcon: hasText && onClear != null
            ? GestureDetector(
                onTap: onClear,
                child: Padding(
                  padding: EdgeInsets.all(postIconPadding ?? 12.0),
                  child: Icon(
                    Icons.close,
                    color: AppColors.grey,
                    size: 20,
                  ),
                ),
              )
            : (posticon != null
                ? GestureDetector(
                    onTap: onpress,
                    child: Padding(
                      padding: EdgeInsets.all(postIconPadding ?? 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 24,
                            width: 1,
                            color: AppColors.grey,
                            margin: EdgeInsets.only(right: 4),
                          ),
                          posticon ?? SizedBox(),
                        ],
                      ),
                    ),
                  )
                : null),
        filled: true,
        fillColor: color ?? AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        enabledBorder: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(25),
          borderSide: BorderSide(color: AppColors.grey400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(25),
          borderSide: BorderSide(color: AppColors.primary1, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: radius ?? BorderRadius.circular(25),
          borderSide: BorderSide(color: AppColors.grey400),
        ),
      ),
    );
  }
}
