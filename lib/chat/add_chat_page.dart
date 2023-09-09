import 'package:chatify/common/variables.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: EdgeInsets.all(screenHeight*0.04), child: IconButton(icon: Icon(Icons.arrow_back), 
          onPressed: () => Navigator.pop(context),)),
          Padding(
            padding: EdgeInsets.all(screenHeight*0.15),
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
        ],
      ),
    );
  }
}
