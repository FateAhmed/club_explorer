import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppStrings.dart';
import 'package:flutter/material.dart';

validateEmail(String value) {
  const String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final RegExp regExp = RegExp(pattern);
  if (value.isEmpty) {
    return 'Email is Required';
  } else if (!regExp.hasMatch(value)) {
    return 'Invalid Email';
  } else {
    return null;
  }
}

validatePassword(String value) {
  if (value.length < 6) {
    return 'The Password must be at least 6 characters.';
  }
  return null;
}

notEmpty(String value) {
  if (value.isEmpty) {
    return 'This field cannot be empty.';
  }
  return null;
}

validateName(
  String value,
) {
  if (value.isEmpty) {
    return 'Name is required';
  }
  return null;
}

Color getColor(String text, FocusNode focus) {
  if (!focus.hasFocus || text == '') {
    return const Color.fromRGBO(161, 161, 161, 1.0);
  }
  if (text.isEmpty) return Colors.redAccent;
  if (text.isNotEmpty) return Colors.black;
  return const Color.fromRGBO(161, 161, 161, 1.0);
}

emailErrorMessage(String text, String errMsg, String badPatternMsg) {
  final pattern = RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  if (text == '') {
    return null;
  } else if (text.isEmpty) {
    return errMsg;
  } else if (!text.contains(pattern)) {
    return badPatternMsg;
  } else {
    return null;
  }
}

errorMessage(String text, String message) {
  if (text == '') {
    return null;
  } else if (text.isEmpty) {
    return message;
  } else {
    return null;
  }
}

class ValidateField {
  static Widget requiredField(bool errorVisible) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, bottom: 7.0),
      child: Visibility(
        visible: errorVisible,
        child: Text(
          AppStrings.requiredField,
          style: const TextStyle(fontSize: 12, color: AppColors.error),
        ),
      ),
    );
  }
}
