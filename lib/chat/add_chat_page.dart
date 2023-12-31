import 'package:chatify/chat/main_page.dart';
import 'package:chatify/common/variables.dart';
import 'package:chatify/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'chats.dart';

class AddChat extends StatefulWidget {
  const AddChat({Key? key, required this.chat}) : super(key: key);
  final Chat chat;
  @override
  State<AddChat> createState() => _AddChatState();
}

class _AddChatState extends State<AddChat> {
  bool userFound = false;
  String searchUsername = '';
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
          Padding(
              padding: EdgeInsets.all(screenHeight * 0.04),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: backButtonSize,
                ),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MainPage())),
              )),
          Align(
              alignment: Alignment.center,
              child: Text(
                'Enter username',
                style: TextStyle(fontSize: 20),
              )),
          Padding(
            padding: EdgeInsets.all(screenHeight * 0.1),
            child: Center(
              child: TextField(
                  textAlign: TextAlign.center,
                  onChanged: (text) async {
                    searchForUsername(text).then((res) => setState(() {
                          searchUsername = text;
                          userFound = res;
                        }));
                    await Future.doWhile(() async {
                      await Future.delayed(const Duration(milliseconds: 1));
                      return text != searchUsername;
                    });
                  }),
            ),
          ),
          userFound
              ? ElevatedButton(
                  child: Row(
                    children: [Text(searchUsername)],
                  ),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                                profileId: searchUsername,
                                chat: widget.chat,
                              ))),
                )
              : Container()
        ],
      ),
    );
  }
}
