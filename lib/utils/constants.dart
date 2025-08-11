import 'package:club_explorer/utils/AppColors.dart';
import 'package:flutter/material.dart';

var kInputDecoration = InputDecoration(
  fillColor: AppColors.secondary,
  filled: true,
  enabledBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFF6F6F7),
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  border: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFF6F6F7),
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  errorBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Color(0xFFF6F6F7),
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedErrorBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);
