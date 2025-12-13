import 'package:explorify/utils/AppColors.dart';
import 'package:flutter/material.dart';

class SmallCard extends StatelessWidget {
  final String text;
  final VoidCallback? onpress;
  final String points;
  const SmallCard({
    super.key,
    required this.text,
    required this.onpress,
    required this.points,
  });
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return Card(
      color: AppColors.white,
      child: SizedBox(
        height: 50,
        width: width * 0.28,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              points,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              text,
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            )
          ],
        ),
      ),
    );
  }
}
