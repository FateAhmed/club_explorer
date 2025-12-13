import 'package:explorify/utils/AppColors.dart';
import 'package:explorify/utils/AppDimens.dart';
import 'package:flutter/material.dart';

class SubscribePackageCard extends StatelessWidget {
  final String title;
  final String desc;
  final String price;
  final Color? border;

  final VoidCallback? onpress;
  final String icon;

  const SubscribePackageCard({
    super.key,
    required this.title,
    required this.desc,
    this.border,
    required this.price,
    required this.onpress,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpress,
      child: Card(
        elevation: 8,
        color: AppColors.white,
        margin: EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: border ?? AppColors.transparent)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Left Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    AppDimens.sizebox5,
                    Text(
                      "$price\$/Mo",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    AppDimens.sizebox5,
                    Text(
                      desc,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              Image.asset(
                icon,
                height: 40,
                width: 40,
              )
            ],
          ),
        ),
      ),
    );
  }
}
