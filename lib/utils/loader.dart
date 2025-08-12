import 'package:flutter/material.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:club_explorer/utils/AppColors.dart';

class LoadingDialog {
  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: AppDimens.padding20,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary1,
              ),
              AppDimens.sizebox15,
              Text(
                'Please wait...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textprimary,
                ),
              ),
              AppDimens.sizebox5,
              Text(
                'We are processing your request',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textsecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
