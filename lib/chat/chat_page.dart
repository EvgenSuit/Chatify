import 'package:chatify/chat/main_page.dart';
import 'package:chatify/profile/profile.dart';
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
  const ChatPage({super.key, required this.profileId, required this.chat});
  final String profileId;
  final Chat chat;
  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late String profileId;
  late Chat chat;
  String? chatId;
  final TextEditingController textEditingController = TextEditingController();
  FlutterListViewController flutterListViewController =
      FlutterListViewController();
  DateTime? upperMessageTimestamp;
  List<GlobalKey> messageKeys = [];
  double? x, y;
  int? messageOptionIndex;
  bool showMessageOptionsOnLeftSide = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      profileId = widget.profileId;
      chat = widget.chat;
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
    if (!internetIsOn) return;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await manageProfilePic(profileId, () => setState(() {}));
    });
  }

  void getMessagePos(GlobalKey key) {
    RenderBox? box = key.currentContext?.findRenderObject() as RenderBox?;
    Offset? pos = box?.localToGlobal(Offset.zero);
    if (pos != null) {
      //make the message options box dissapear when its position changes
      if (y != null && (pos.dy != y || pos.dx != x)) {
        setState(() {
          x = null;
          y = null;
          messageOptionIndex = null;
        });
        return;
      }

      if (pos.dy == y || pos.dx == x) {
        return;
      }
      setState(() {
        x = pos.dx;
        y = pos.dy;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => chat,
      child: Consumer<Chat>(
        builder: ((context, chat, child) {
          return Scaffold(
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: SizedBox(
                height: screenHeight,
                child: Stack(children: [
                  const Metaballs(
                    color: Colors.lightGreenAccent,
                  ),
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
                            ? Positioned(
                                left: screenWidth * 0.4,
                                child: Text(
                                  '${upperMessageTimestamp!.day.toString()} ${DateFormat('MMMM').format(DateTime(0, upperMessageTimestamp!.month))}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17),
                                ),
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
                      ),
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
    return Stack(children: [
      SizedBox(
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
                    child: messageWidget(message, index),
                    onVisibilityChanged: (info) => setState(() {
                          upperMessageTimestamp = DateTime.parse(
                              reversedMessages[messagesKeys[index]]
                                  ['timestamp']);
                        })),
              );
            },
            childCount: chat.messages[chatId] != null
                ? chat.messages[chatId]!.keys.length
                : 0,
          ),
        ),
      ),
      x != null && y != null ? messageOptionsWidget() : Container()
    ]);
  }

  Widget messageOptionsWidget() {
    return Positioned(
      left: showMessageOptionsOnLeftSide
          ? (screenWidth * 0.5) - x!
          : x! + (screenWidth * 0.5),
      bottom: (screenHeight - y!) -
          (screenHeight * 0.1) -
          MediaQuery.of(context).viewInsets.bottom,
      child: TapRegion(
        onTapOutside: (tap) => setState(() {
          x = null;
          y = null;
          messageOptionIndex = null;
        }),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            blendMode: BlendMode.hardLight,
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: screenHeight * 0.2,
              width: screenWidth * 0.5,
              decoration: const BoxDecoration(boxShadow: [
                BoxShadow(color: Colors.black87, spreadRadius: 0.5)
              ]),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        'Change',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget messageWidget(Map message, int index) {
    final DateTime date = DateTime.parse(message['timestamp']);
    final hourMinute = '${date.hour}:${date.minute}';
    final showMessageOnLeftSide = message['sender'] == currentUsername;

    if (messageKeys.length == index) {
      messageKeys.add(GlobalKey());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messageOptionIndex != null && mounted) {
        getMessagePos(messageKeys[messageOptionIndex!]);
      }
    });
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: showMessageOnLeftSide
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          TapRegion(
            key: messageKeys[index],
            child: SizedBox(
              width: screenWidth * 0.5,
              child: ElevatedButton(
                onLongPress: () {
                  setState(() {
                    messageOptionIndex = index;
                    showMessageOptionsOnLeftSide = !showMessageOnLeftSide;
                  });
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20))),
                onPressed: () {},
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, screenHeight * 0.01, 0, screenHeight * 0.01),
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
                            chat: chat,
                          ))),
            ),
            SizedBox(
              width: screenWidth * 0.1,
            ),
            Text(
              profileId,
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.w900),
            )
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

                chatId = '${currentUsername}_$profileId';
                final reversedChatId = '${profileId}_$currentUsername';
                final currentUserChatsKeys = chat.currentUserChats.keys;
                if (currentUserChatsKeys.isNotEmpty) {
                  for (String key in currentUserChatsKeys) {
                    final split = key.split('_');
                    if (split[0] != currentUsername) {
                      chatId = reversedChatId;
                    }
                  }
                }

                if (!currentUserChatsKeys.contains(chatId) &&
                    !currentUserChatsKeys
                        .contains('${profileId}_$currentUsername')) {
                  await chat.addChat(profileId);
                }
                await chat.sendMessage([currentUsername!, profileId],
                    chat.currentMessage, chatId!);

                await chat.getChat(chatId!);
                textEditingController.clear();
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
