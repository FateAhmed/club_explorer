import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/TextFieldStyle.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final String? title;
  final Function? onTap;
  final Function? onChange;
  final Function? onFieldSubmitted;
  final double? radius;
  final bool readOnly;
  final bool required = true;
  final double bottomPadding;
  final bool obscure;
  final TextInputType textInputType;
  final TextInputAction textInputAction;
  final bool isForm;
  final bool autoFocus;
  final bool? enable;
  final int? maxLines;
  final FocusNode focusNode;
  final Function validator;
  final String? prefixicon;
  final Widget? suffixicon;
  final Function? iconPressed;
  final InputDecoration? inputDecoration;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.validator,
    this.inputDecoration,
    this.iconPressed,
    this.prefixicon,
    this.suffixicon,
    this.enable = true,
    this.hintText = '',
    this.title,
    this.radius,
    this.maxLines = 1,
    this.onTap,
    this.onChange,
    this.onFieldSubmitted,
    this.textInputType = TextInputType.text,
    this.autoFocus = false,
    this.obscure = false,
    this.bottomPadding = 16,
    this.textInputAction = TextInputAction.done,
    this.isForm = false,
    this.readOnly = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool isFocusedOrFilled;

  @override
  void initState() {
    super.initState();
    isFocusedOrFilled =
        widget.controller.text.isNotEmpty || widget.focusNode.hasFocus;

    widget.controller.addListener(_updateState);
    widget.focusNode.addListener(_updateState);
  }

  void _updateState() {
    final newState =
        widget.controller.text.isNotEmpty || widget.focusNode.hasFocus;

    if (newState != isFocusedOrFilled) {
      setState(() {
        isFocusedOrFilled = newState;
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_updateState);
    widget.focusNode.removeListener(_updateState);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color currentColor =
        isFocusedOrFilled ? AppColors.textprimary : AppColors.grey;

    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      enabled: widget.enable,
      readOnly: widget.readOnly,
      obscureText: widget.obscure,
      keyboardType: widget.textInputType,
      textInputAction: widget.textInputAction,
      cursorColor: AppColors.primary2,
      maxLines: widget.maxLines,
      autofocus: widget.autoFocus,
      autovalidateMode: AutovalidateMode.disabled,
      validator: (value) => widget.validator(value),
      onTapOutside: (event) => widget.focusNode.unfocus(),
      onChanged: (a) => widget.onChange != null ? widget.onChange!(a) : () {},
      onTap: () => widget.onTap != null ? widget.onTap!() : () {},
      onFieldSubmitted: (val) {
        if (widget.onFieldSubmitted != null) widget.onFieldSubmitted!(val);
      },
      decoration: widget.inputDecoration?.copyWith(
            hintText: widget.title,
            prefixIcon: widget.prefixicon != null
                ? Image.asset(
                    widget.prefixicon!,
                    height: 16,
                    width: 16,
                    color: currentColor,
                  )
                : null,
          ) ??
          TextFieldStyle.focusOutlined().copyWith(
            hintText: widget.title,
            hintStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.grey),
            fillColor: AppColors.grey100,
            prefixIcon: widget.prefixicon != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset(
                      widget.prefixicon!,
                      height: 16,
                      width: 16,
                      color: currentColor,
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minHeight: 16,
              minWidth: 16,
              maxHeight: 40,
              maxWidth: 40,
            ),
            suffixIcon: widget.suffixicon != null
                ? GestureDetector(
                    onTap: () {
                      widget.iconPressed?.call();
                    },
                    child: widget.suffixicon,
                  )
                : null,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 10),
              borderSide: BorderSide(color: currentColor),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 10),
              borderSide: BorderSide(color: currentColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.radius ?? 10),
              borderSide: BorderSide(color: currentColor),
            ),
          ),
    );
  }
}
