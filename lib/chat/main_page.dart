import 'package:chatify/auth/auth_page.dart';
import 'package:chatify/profile/profile_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/variables.dart';
import '../common/widgets.dart';
import 'chats.dart';
import 'add_chat_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
    //FirebaseDatabase.instance.setPersistenceEnabled(true);
    currentUsername ??= prefs!.getString('currentUsername');
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
      /*body: SizedBox(
            height: screenHeight * 0.7,
            child: chatProvider.allChats.isEmpty
                ? FutureBuilder(
                    future: chatProvider.getAllChats(),
                    builder: ((context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return chatList(chatProvider);
                      } else {
                        return Center(
                          child: Text('No chats'),
                        );
                      }
                    }))
                : chatList(chatProvider)), */
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => AddChat()))),
    );
  }

  Widget chatList() {
    return ListView.builder(
        itemCount: allChats.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Row(
            children: [
              //userPic,
              Column(
                children: [Text(allChats[index].toString())],
              )
            ],
          );
        });
  }
}
