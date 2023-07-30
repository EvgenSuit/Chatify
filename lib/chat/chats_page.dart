import 'package:flutter/material.dart';
import '../common/variables.dart';
import '../common/widgets.dart';
import 'chats.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({Key? key}) : super(key: key);

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  @override
  void initState() {
    super.initState();

    checkForChats();
  }

  @override
  Widget build(BuildContext context) {
    authErrorMessage.addListener(
        () => showSnackBar(context: context, content: authErrorMessage.value));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatify'),
        centerTitle: true,
        toolbarHeight: 60,
        elevation: 20,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(70),
                bottomRight: Radius.circular(70))),
      ),
      body: FutureBuilder(
        future: checkForChats(),
        builder: ((context, snapshot) {
          print(snapshot.connectionState);
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
              return Center(
                  child: const Text("Tap 'add' button to start chatting"));
            }
          } else {
            return Container();
          }
        }),
      ),
      floatingActionButton: const FloatingActionButton(
          child: const Icon(Icons.add), onPressed: null),
    );
  }
}
