import 'package:chatify/auth/auth_page.dart';
import 'package:chatify/chat/chat_page.dart';
import 'package:chatify/profile/profile_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/variables.dart';
import '../common/widgets.dart';
import 'chats.dart';
import 'add_chat_page.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    //FirebaseDatabase.instance.setPersistenceEnabled(true);
    setState(() {
      currentUsername ??= prefs!.getString('currentUsername');
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await chat.getLastMessages();
      setState(() {});
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    authErrorMessage.addListener(
        () => showSnackBar(context: context, content: authErrorMessage.value));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatify'),
        leading: Row(children: [
          Expanded(
              child: IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AuthPage())),
                  icon: const Icon(Icons.arrow_back))),
          Expanded(
              child: IconButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProfileScreen(
                                profileId: currentUsername!,
                              ))),
                  icon: const Icon(Icons.person)))
        ]),
        centerTitle: true,
        toolbarHeight: 60,
        elevation: 20,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
      ),
      body: chatList(),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddChat()))),
    );
  }

  Widget chatList() {
    return ListView.builder(
        itemCount: chat.lastMessages.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final lastMessage = chat.lastMessages[index];
          if (lastMessage.runtimeType == String) return Container();
          final DateTime date = DateTime.parse(lastMessage['timestamp']);
          final hourMinute = '${date.hour}:${date.minute}';
          return SizedBox(
            width: screenWidth,
            height: screenHeight * 0.07,
            child: Container(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lastMessage['sender'],
                    textAlign: TextAlign.justify,
                  ),
                  SizedBox(
                    height: screenHeight * 0.01,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(lastMessage['message'])),
                      Text(hourMinute)
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }
}
