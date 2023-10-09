import 'package:chatify/auth/auth_page.dart';
import 'package:chatify/chat/chat_page.dart';
import 'package:chatify/profile/profile_screen.dart';
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
    setState(() {
      currentUsername ??= prefs!.getString('currentUsername');
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await chat.getLastMessages();

      /*await Future.doWhile(
        () async {
          await Future.delayed(const Duration(milliseconds: 10));

          return chat.messages.isEmpty ||
              chat.lastMessages.length != chat.currentUserChats.length;
        },
      );
      await Future.delayed(const Duration(milliseconds: 1000)); */
    });
  }

  @override
  Widget build(BuildContext context) {
    authErrorMessage.addListener(
        () => showSnackBar(context: context, content: authErrorMessage.value));
    return ChangeNotifierProvider(
      create: (_) => chat,
      child: Consumer<Chat>(builder: ((context, chat, child) {
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
          body: /*ValueListenableBuilder(
          valueListenable: chat.lastMessages,
          builder: ((context, value, child) => chatList(value))), */
              chatList(),
          floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddChat()))),
        );
      })),
    );
  }

  Widget chatList() {
    return ListView.builder(
        itemCount: chat.lastMessages.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final keys = chat.currentUserChats.keys.toList();
          chat.chatId = keys[index];
          Map lastMessage =
              chat.lastMessages[chat.currentUserChats[keys[index]]];
          DateTime date = DateTime.parse(lastMessage['timestamp']);
          final hourMinute = '${date.hour}:${date.minute}';

          return ElevatedButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatPage(
                          profileId: lastMessage['receiver'],
                        ))),
            child: SizedBox(
              width: screenWidth,
              height: screenHeight * 0.07,
              child: Container(
                decoration: const BoxDecoration(color: Colors.blue),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lastMessage['receiver'],
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
            ),
          );
        });
  }
}
