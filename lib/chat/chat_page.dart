import 'package:chatify/chat/main_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:chatify/chat/chats.dart';
import 'package:chatify/common/variables.dart';
import 'package:chatify/common/widgets.dart';
import 'package:chatify/profile/profile_screen.dart';
import 'package:chatify/profile/profile_variables.dart';
import 'package:flutter/material.dart';
import 'package:metaballs/metaballs.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.profileId});
  final String profileId;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String profileId;
  String? chatId;
  final TextEditingController textEditingController = TextEditingController();
  late ItemScrollController itemScrollController;
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();
  DateTime? upperMessageTimestemp;

  @override
  void initState() {
    super.initState();
    setState(() {
      itemScrollController = ItemScrollController();
      profileId = widget.profileId;
      chatId = '${currentUsername}_$profileId';
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await chat.getLastMessages();
      await Future.doWhile(() async {
        await Future.delayed(const Duration(milliseconds: 20));
        return !itemScrollController.isAttached;
      });
      final chatKeys = chat.lastMessages.keys;
      for (String key in chatKeys) {
        if (key.contains(currentUsername!) && key.contains(profileId)) {
          setState(() {
            chatId = key;
          });
        }
      }
      await scrollDown(chat.messages[chatId].length - 1);
    });
    itemPositionsListener.itemPositions.addListener(() {
      final upperMessage = itemPositionsListener.itemPositions.value.toList();
      if (upperMessage.isEmpty) return;
      final upperMessageIndex = upperMessage[0].index;
      Map message = chat.messages[chatId];
      String key = message.keys.toList()[upperMessageIndex];

      upperMessageTimestemp = DateTime.parse(message[key]['timestamp']);
      setState(() {});
    });
  }

  Future scrollDown(int lastIndex) async {
    await itemScrollController.scrollTo(
        index: lastIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInExpo);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => chat,
      child: Consumer<Chat>(
        builder: ((context, chat, child) {
          return Scaffold(
            body: SingleChildScrollView(
              child: SizedBox(
                height: screenHeight,
                child: Stack(children: [
                  const Metaballs(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.topCenter,
                          child: ClipRRect(
                            child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 13, sigmaY: 13),
                                child: Container(
                                    color: Colors.transparent,
                                    child: upperWidget())),
                          )),
                      const Spacer(),
                      Stack(children: [
                        SizedBox(
                            height: screenHeight * 0.75, child: messagesList()),
                        upperMessageTimestemp != null
                            ? Center(
                                child: Text(
                                    '${upperMessageTimestemp!.day.toString()} ${DateFormat('MMMM').format(DateTime(0, upperMessageTimestemp!.month))}'),
                              )
                            : Container(),
                      ]),
                      ClipRRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                            child: Container(
                              color: Colors.transparent,
                              child: bottomWidget(chat),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget messagesList() {
    return ScrollablePositionedList.builder(
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        itemCount: chat.messages.containsKey(chatId)
            ? chat.messages[chatId].keys.length
            : 0,
        itemBuilder: ((context, index) {
          final keys = chat.messages[chatId].keys.toList();
          Map message = chat.messages[chatId][keys[index]];
          try {
            return messageWidget(message);
          } catch (e) {
            message = message[message.keys.toList()[0]];
            return messageWidget(message);
          }
        }));
  }

  Widget messageWidget(Map message) {
    final DateTime date = DateTime.parse(message['timestamp']);
    final hourMinute = '${date.hour}:${date.minute}';

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: message['sender'] == currentUsername
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Container(
            decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(Radius.circular(30))),
            width: screenWidth * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['sender'],
                      textAlign: TextAlign.justify,
                    ),
                    SizedBox(
                      height: screenHeight * 0.01,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(message['message'])),
                        Text(hourMinute)
                      ],
                    )
                  ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget upperWidget() {
    return Container(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.1, color: Colors.black))),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            screenWidth * 0.01, screenHeight * 0.05, 0, screenHeight * 0.01),
        child: Row(
          children: [
            IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MainPage())),
                icon: Icon(
                  Icons.arrow_back,
                  size: backButtonSize,
                )),
            SizedBox(
              width: screenWidth * 0.02,
            ),
            ElevatedButton(
              clipBehavior: Clip.antiAlias,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.zero),
              child: !usersProfilePics.containsKey(profileId)
                  ? Image.asset(
                      'assets/default_profile_picture.jpg',
                      fit: BoxFit.cover,
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.16,
                    )
                  : Image.file(
                      usersProfilePics[profileId],
                      fit: BoxFit.fill,
                      height: screenHeight * 0.08,
                      width: screenWidth * 0.16,
                    ),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            profileId: profileId,
                          ))),
            ),
            Text(profileId)
          ],
        ),
      ),
    );
  }

  Widget bottomWidget(Chat chat) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: screenWidth * 0.7,
          height: screenHeight * 0.1,
          child: TextField(
            controller: textEditingController,
            onChanged: (text) {
              setState(() {
                chat.currentMessage = text;
              });
            },
          ),
        ),
        SizedBox(
          width: screenWidth * 0.05,
        ),
        SizedBox(
          width: screenWidth * 0.16,
          height: screenHeight * 0.07,
          child: ElevatedButton(
              style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)))),
              onPressed: () async {
                //change !internetIsOn to waiting for internet connection!
                if (!checkEmptyText(chat.currentMessage) || !internetIsOn)
                  return;
                setState(() {
                  chat.receiver = profileId;
                });
                if (!chat.currentUserChats.keys.contains(chatId)) {
                  await chat.addChat();
                }
                await chat.sendMessage([currentUsername!, profileId],
                    chat.currentMessage, chatId!);

                await chat.getChat(chatId!);
                textEditingController.clear();
                final messagesLength = chat.messages[chatId!].length;
                if (messagesLength == 1) return;
                await scrollDown(chat.messages[chatId!].length - 1);
              },
              child: Icon(
                Icons.send,
                size: screenWidth * 0.1,
              )),
        )
      ],
    );
  }
}
