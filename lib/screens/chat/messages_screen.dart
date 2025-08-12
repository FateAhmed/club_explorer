import 'package:club_explorer/components/search_field.dart';
import 'package:club_explorer/components/theme_button.dart';
import 'package:club_explorer/screens/chat/chat.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final List<Map<String, dynamic>> messages = [
    {
      "name": "Miss Dolores, Schowalter +25",
      "message": "Thank you! 😁",
      "time": "7:12 AM",
      "avatar": "assets/icons/sample-user.png",
      "unreadCount": 3,
    },
    {
      "name": "Lorena Farrell",
      "message": "Yes! please take a order",
      "time": "9:28 AM",
      "avatar": "assets/icons/sample-user.png",
    },
    {
      "name": "Amos Hessel",
      "message": "I think this one is good",
      "time": "4:35 PM",
      "avatar": "assets/icons/sample-user.png",
    },
    {
      "name": "Ollie Haley",
      "message": "Wow, this is really epic",
      "time": "8:12 PM",
      "avatar": "assets/icons/sample-user.png",
    },
    {
      "name": "Traci Maggio",
      "message": "omg, this is amazing",
      "time": "10:22 PM",
      "avatar": "assets/icons/sample-user.png",
    },
  ];

  bool isGroup = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message'),
        centerTitle: true,
        backgroundColor: AppColors.grey50,
      ),
      backgroundColor: AppColors.grey50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              AppDimens.sizebox10,
              SearchField(
                text: 'Search...',
                onpress: () {},
                preicon: Image.asset(
                  'assets/icons/search.png',
                  height: 30,
                  width: 30,
                ),
                posticon: Image.asset(
                  'assets/icons/filter.png',
                  height: 30,
                  width: 30,
                ),
              ),
              AppDimens.sizebox10,
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  itemCount: messages.length,
                  separatorBuilder: (context, index) => const Divider(
                    thickness: 0.5,
                  ),
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    return ListTile(
                      onTap: () {
                        Get.to(() => InChat(
                              name: msg["name"],
                            ));
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0), // remove internal padding
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(msg["avatar"]),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              msg["name"],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            msg["time"],
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              msg["message"],
                              style: const TextStyle(color: Colors.grey, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (msg["unreadCount"] != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              margin: const EdgeInsets.only(left: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.notification,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                "${msg["unreadCount"]}",
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        backgroundColor: AppColors.primary1,
        foregroundColor: AppColors.white,
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
