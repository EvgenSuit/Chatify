import 'package:chatify/auth/auth_page.dart';
import 'package:chatify/chat/chat_page.dart';
import 'package:chatify/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      //await box.erase();
    });
  }

  @override
  Widget build(BuildContext context) {
    authErrorMessage.addListener(
        () => showSnackBar(context: context, content: authErrorMessage.value));
    return ChangeNotifierProvider(
      create: (_) => Chat(),
      child: Consumer<Chat>(builder: ((context, chat, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Chatify'),
            leading: Row(children: [
              Expanded(
                  child: IconButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AuthPage()),
                            (Route<dynamic> route) => false);
                      },
                      icon: const Icon(Icons.arrow_back))),
              Expanded(
                  child: IconButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfileScreen(
                                    profileId: currentUsername!,
                                    chat: chat,
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
          body: chatList(chat),
          floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AddChat(
                            chat: chat,
                          )))),
        );
      })),
    );
  }

  Widget chatList(Chat chat) {
    return ListView.builder(
        itemCount: chat.lastMessages.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final keys = chat.currentUserChats.keys.toList();
          Map? lastMessage =
              chat.lastMessages[chat.currentUserChats[keys[index]]];
          if (lastMessage == null) {
            return Container();
          }
          final Jiffy time = Jiffy.parse(lastMessage!['timestamp']);
          final now = Jiffy.now();
          final timeString = "${now.year != time.year ? time.year : ''}"
              "${now.month != time.month ? time.MMM : ''}"
              "${now.dayOfWeek != time.dayOfWeek ? time.E : ''}"
              " ${time.Hm}";
          final receiver = lastMessage['receiver'] == currentUsername
              ? lastMessage['sender']
              : lastMessage['receiver'];
          return ElevatedButton(
              style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 0.5, color: Colors.black),
                  backgroundColor: Colors.blue),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChatPage(profileId: receiver, chat: chat))),
              child: chatWidgetBody(receiver, lastMessage, timeString));
        });
  }

  Widget chatWidgetBody(String receiver, Map lastMessage, String time) {
    return SizedBox(
      width: screenWidth,
      height: screenHeight * 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            receiver,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Row(
            children: [
              for (int i = 0;
                  i < (screenWidth * 0.12).toInt() &&
                      i < lastMessage['message'].length;
                  i++)
                Text(lastMessage['message'][i]),
              if ((screenWidth * 0.12).toInt() < lastMessage['message'].length)
                const Text("..."),
              const Spacer(),
            ],
          ),
          SizedBox(
            height: screenHeight * 0.01,
          ),
          Text(
            time,
            textAlign: TextAlign.end,
          )
        ],
      ),
    );
  }
}
