import 'package:chatify/auth/auth_page.dart';
import 'package:chatify/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/variables.dart';
import '../common/widgets.dart';
import 'chats.dart';
import 'add_chat_page.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);
  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  void initState() {
    super.initState();
    currentUsername = prefs!.getString('currentUsername');
    checkForChats();
  }

  @override
  Widget build(BuildContext context) {
    authErrorMessage.addListener(
        () => showSnackBar(context: context, content: authErrorMessage.value));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatify'),
        leading: Row(children: [
          Expanded(child: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AuthPage())), icon: Icon(Icons.arrow_back))),
          Expanded(child: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen())), icon: Icon(Icons.person)))
        ]),
        centerTitle: true,
        toolbarHeight: 60,
        elevation: 20,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30))),
      ),
      body: FutureBuilder(
        future: checkForChats(),
        builder: ((context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.connectionState == ConnectionState.done) {
            if (chatsExist) {
              return ListView.builder(itemBuilder: (context, index) {
                return Container();
              });
            } else {
              return const Center(
                  child: Text("Tap 'add' button to start chatting"));
            }
          } else {
            return Container();
          }
        }),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddChat()))),
    );
  }
}
