import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chats.dart';

class AddChat extends StatefulWidget {
  const AddChat({Key? key}) : super(key: key);

  @override
  State<AddChat> createState() => _AddChatState();
}

class _AddChatState extends State<AddChat> {
  bool userFound = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Center(
          child: TextField(
              textAlign: TextAlign.center,
              onChanged: (searchUsername) async {
                final res = await searchForUsername(searchUsername);
                setState(() {
                  userFound = res;
                });
                print(userFound);
                if (userFound) await addChat(searchUsername);
              }),
        ),
      ),
    );
  }
}
