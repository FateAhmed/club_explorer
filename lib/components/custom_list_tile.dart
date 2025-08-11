import 'package:club_explorer/utils/AppColors.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  final String text;
  final VoidCallback? onpress;
  final Widget preicon;
  final Icon posticon;
  const CustomListTile({
    super.key,
    required this.text,
    required this.onpress,
    required this.preicon,
    required this.posticon,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onpress,
      leading: SizedBox(height: 28, width: 28, child: preicon),
      tileColor: AppColors.transparent,
      title: Text(
        text,
        style: TextStyle(fontSize: 18),
      ),
      trailing: posticon,
      contentPadding: EdgeInsets.only(bottom: 16),
    );
  }
}
