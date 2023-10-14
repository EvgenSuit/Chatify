import 'package:chatify/chat/main_page.dart';
import 'package:flutter_list_view/flutter_list_view.dart';
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
import 'package:visibility_detector/visibility_detector.dart';

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
  FlutterListViewController flutterListViewController =
      FlutterListViewController();
  DateTime? upperMessageTimestamp;

  @override
  void initState() {
    super.initState();
    setState(() {
      profileId = widget.profileId;
      chat.receiver = profileId;
    });

    final chatKeys = chat.lastMessages.keys;
    for (String key in chatKeys) {
      if (key.contains(currentUsername!) && key.contains(profileId)) {
        setState(() {
          chatId = key;
        });
      }
    }
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
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
                        messagesList(),
                        upperMessageTimestamp != null
                            ? Center(
                                child: Text(
                                    '${upperMessageTimestamp!.day.toString()} ${DateFormat('MMMM').format(DateTime(0, upperMessageTimestamp!.month))}'),
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
    return SizedBox(
      height: screenHeight * 0.75,
      child: FlutterListView(
        controller: flutterListViewController,
        reverse: true,
        shrinkWrap: true,
        delegate: FlutterListViewDelegate(
          (context, index) {
            final reversedMessages = Map.fromEntries(
                chat.messages[chatId]!.entries.toList().reversed);
            final messagesKeys = reversedMessages.keys.toList();
            final message = reversedMessages[messagesKeys[index]];
            return SizedBox(
              child: VisibilityDetector(
                  key: Key(index.toString()),
                  child: messageWidget(message),
                  onVisibilityChanged: (info) => setState(() {
                        upperMessageTimestamp = DateTime.parse(
                            reversedMessages[messagesKeys[index]]['timestamp']);
                      })),
            );
          },
          childCount: chat.messages[chatId] != null
              ? chat.messages[chatId]!.keys.length
              : 0,
        ),
      ),
    );
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
                String? chatIdTemp = chatId;
                if (!chat.currentUserChats.keys.contains(chatId)) {
                  setState(() {
                    chatId = chatIdTemp;
                  });
                  chatIdTemp = await chat.addChat(profileId);
                }
                await chat.sendMessage([currentUsername!, profileId],
                    chat.currentMessage, chatIdTemp!);

                await chat.getLastMessages();
                textEditingController.clear();
                final messagesLength = chat.messages[chatId].length;
                if (messagesLength <= 1) return;
                //flutterListViewController.sliverController.jumpToIndex(messagesLength - 1);
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
