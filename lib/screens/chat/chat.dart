import 'package:club_explorer/components/theme_field.dart';
import 'package:club_explorer/utils/AppColors.dart';
import 'package:club_explorer/utils/AppDimens.dart';
import 'package:club_explorer/utils/Validations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InChat extends StatefulWidget {
  final String name;

  const InChat({super.key, required this.name});

  @override
  State<InChat> createState() => _InChatState();
}

class _InChatState extends State<InChat> {
  TextEditingController chatController = TextEditingController();

  // List to store messages
  List<Map<String, dynamic>> messages = [
    {
      "text":
          "hi for this hotel with a king sweet room are there still any vacancies?",
      "isSent": true,
      "time": "10.15 AM"
    },
    {
      "text": "Hi Ahmir",
      "isSent": false,
      "time": "10.30 AM",
      "showAvatar": true,
    },
    {
      "text": "Yes the room is available, so you can make an order.",
      "isSent": false,
      "time": "10.31 AM",
      "showAvatar": false,
    },
  ];

  void sendMessage() {
    final text = chatController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({
          "text": text,
          "isSent": true,
          "time": TimeOfDay.now().format(context),
        });
      });
      chatController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  AppDimens.sizebox20,
                  Center(
                    child: Text(
                      'Chat',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  AppDimens.sizebox20,
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 24,
                              backgroundImage:
                                  AssetImage('assets/icons/sample-user.png'),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.name,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              "Online",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 0),

                  // Updated Message List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0, vertical: 10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        if (msg["isSent"]) {
                          return Align(
                            alignment: Alignment.centerRight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.65),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD6B45D),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    msg["text"],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                Text(
                                  msg["time"] ?? '',
                                  style: const TextStyle(
                                      fontSize: 10, color: Colors.grey),
                                ),
                                AppDimens.sizebox15
                              ],
                            ),
                          );
                        } else {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (msg["showAvatar"] == true)
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundImage:
                                      AssetImage('assets/images/user2.jpg'),
                                )
                              else
                                const SizedBox(width: 40),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (msg["showAvatar"] == true)
                                    const Text("Doen Johns",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.65),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(msg["text"]),
                                  ),
                                  Text(
                                    msg["time"] ?? '',
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),

                  // Input Field
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextFormField(
                          controller: chatController,
                          title: 'Write a reply',
                          radius: 40,
                          prefixicon: 'assets/icons/paperclip.png',
                          suffixicon: GestureDetector(
                            onTap: sendMessage,
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(0, 1, 3, 1),
                              height: 48,
                              width: 48,
                              decoration: const BoxDecoration(
                                color: AppColors.primary1,
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset('assets/icons/send.png'),
                            ),
                          ),
                          onTap: sendMessage,
                          focusNode: FocusNode(),
                          validator: (e) => notEmpty(e),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Image.asset(
                  'assets/icons/arrow_back.png',
                  height: 30,
                  width: 30,
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                onPressed: () {
                  // Add more options here
                },
                icon: const Icon(Icons.more_vert),
              ),
            )
          ],
        ),
      ),
    );
  }
}
