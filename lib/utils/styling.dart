import 'package:explorify/utils/AppColors.dart';
import 'package:flutter/material.dart';

InputDecoration kInputDecoration = InputDecoration(
  fillColor: AppColors.secondary.withOpacity(1),
  filled: true,
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColors.grey,
      width: 3.0,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
  ),
  border: OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColors.grey,
      width: 3.0,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
  ),
  errorBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(
      color: AppColors.grey,
      width: 3.0,
    ),
    borderRadius: const BorderRadius.all(Radius.circular(10.0)),
  ),
  focusedErrorBorder: const OutlineInputBorder(
    borderSide: BorderSide(
      color: Colors.red,
      width: 3.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
  ),
);
