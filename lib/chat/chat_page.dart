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
import 'package:jiffy/jiffy.dart';
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
  final TextEditingController textEditingController = TextEditingController();
  FlutterListViewController flutterListViewController =
      FlutterListViewController();
  DateTime? upperMessageTimestamp;
  List<GlobalKey> messageKeys = [];
  double? x, y;
  int? messageOptionsIndex;
  bool showMessageOptionsOnLeftSide = false;
  late FocusNode keyboardFocus;
  bool changeMessage = false;
  bool sendMessagePressed = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      keyboardFocus = FocusNode();
      profileId = widget.profileId;
      chat = widget.chat;
    });
    VisibilityDetectorController.instance.updateInterval = Duration.zero;

    Map usernameToIdMap = box.read('usernameToIdMap') ?? {};
    if (usernameToIdMap.keys.contains(currentUsername) &&
        usernameToIdMap.keys.contains(profileId)) {
      for (String id in chat.currentUserChats.keys) {
        if (id.contains(usernameToIdMap[currentUsername]) &&
            id.contains(usernameToIdMap[profileId])) {
          setState(() {
            chat.chatId = id;
          });
        }
      }
    } else {
      if (!internetIsOn) return;
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        final currentUserId =
            (await usersRef.child(currentUsername!).child('userId').get())
                .value
                .toString();
        final receiverId =
            (await usersRef.child(profileId).child('userId').get())
                .value
                .toString();
        for (String id in chat.currentUserChats.keys) {
          if (id.contains(currentUserId) && id.contains(receiverId)) {
            setState(() {
              chat.chatId = id;
              usernameToIdMap[currentUsername] = currentUserId;
              usernameToIdMap[profileId] = receiverId;
            });
            chat.usernameToIdMap = usernameToIdMap;
            await box.write('usernameToIdMap', chat.usernameToIdMap);
          }
        }
      });
    }
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
        });
        if (!changeMessage) {
          messageOptionsIndex = null;
        }
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

  DateTime? separateByDate(DateTime currentMessageDate, int currentIndex,
      Map reversedMessages, List messagesKeys) {
    DateTime? separateMessageDate;
    void checkDate(
        DateTime otherDatetime, DateTime currentDatetime, int index) {
      if (otherDatetime.year != currentDatetime.year ||
          otherDatetime.month != currentDatetime.month ||
          otherDatetime.day != currentDatetime.day) {
        separateMessageDate = currentDatetime;
      }
    }

    if (currentIndex + 1 < messagesKeys.length) {
      final nextMessageDate = DateTime.parse(
          reversedMessages[messagesKeys[currentIndex + 1]]['timestamp']);
      checkDate(nextMessageDate, currentMessageDate, currentIndex);
    }
    return separateMessageDate;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => chat,
      child: Consumer<Chat>(
        builder: ((context, chat, child) {
          return Scaffold(
            //resizeToAvoidBottomInset: true,
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
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: Colors.amberAccent),
                                  child: Text(
                                    '${upperMessageTimestamp!.day.toString()} ${DateFormat('MMMM').format(DateTime(0, upperMessageTimestamp!.month))}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17),
                                  ),
                                ))
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
    if (chat.messages[chat.chatId] == null) {
      return Container();
    }
    Map reversedMessages =
        Map.fromEntries(chat.messages[chat.chatId]?.entries.toList().reversed);
    final messagesKeys = reversedMessages.keys.toList();
    return Stack(children: [
      SizedBox(
        height: screenHeight * 0.75,
        child: FlutterListView(
          controller: flutterListViewController,
          reverse: true,
          shrinkWrap: true,
          delegate: FlutterListViewDelegate(
            (context, index) {
              final message = reversedMessages[messagesKeys[index]];
              final date = DateTime.parse(message['timestamp']);

              final DateTime? separateMessageDate =
                  separateByDate(date, index, reversedMessages, messagesKeys);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  separateMessageDate != null
                      ? Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            "${separateMessageDate.day} ${DateFormat("MMMM").format(separateMessageDate)}",
                            textAlign: TextAlign.center,
                          ),
                        )
                      : Container(),
                  VisibilityDetector(
                      key: Key(index.toString()),
                      child: messageWidget(message, index, date),
                      onVisibilityChanged: (info) => setState(() {
                            upperMessageTimestamp = DateTime.parse(
                                reversedMessages[messagesKeys[index]]
                                    ['timestamp']);
                          })),
                ],
              );
            },
            childCount: chat.messages[chat.chatId] != null
                ? chat.messages[chat.chatId]!.keys.length
                : 0,
          ),
        ),
      ),
      x != null && y != null ? messageOptionsWidget() : Container()
    ]);
  }

  Widget messageWidget(Map message, int index, DateTime date) {
    final hourMinute = '${date.hour}:${date.minute}';
    final showMessageOnLeftSide = message['sender'] == currentUsername;
    if (messageKeys.length == index) {
      messageKeys.add(GlobalKey());
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (messageOptionsIndex != null && mounted) {
        getMessagePos(messageKeys[messageOptionsIndex!]);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        mainAxisAlignment: showMessageOnLeftSide
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          TapRegion(
            key: messageKeys[index],
            child: SizedBox(
              width: screenWidth * 0.5,
              child: ElevatedButton(
                onLongPress: () {
                  setState(() {
                    messageOptionsIndex = index;
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
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          message['sender'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        SizedBox(
                          height: screenHeight * 0.01,
                        ),
                        Text(
                          message['message'],
                          textAlign: TextAlign.start,
                        ),
                        Text(
                          hourMinute,
                          textAlign: TextAlign.end,
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

  Widget messageOptionsWidget() {
    return Positioned(
      left: showMessageOptionsOnLeftSide
          ? (screenWidth * 0.7) - x!
          : x! + (screenWidth * 0.3),
      bottom: (screenHeight - y!) -
          (screenHeight * 0.18) -
          MediaQuery.of(context).viewInsets.bottom,
      child: TapRegion(
        onTapOutside: (tap) => setState(() {
          x = null;
          y = null;
          if (!changeMessage) {
            messageOptionsIndex = null;
          }
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
                      onPressed: () async => await chat.removeMessage(
                          chat.chatId,
                          chat.messages[chat.chatId].length -
                              1 -
                              messageOptionsIndex,
                          true),
                      child: const Text(
                        'Delete',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        keyboardFocus.requestFocus();
                        final chatMessages =
                            chat.messages[chat.chatId].values.toList();
                        setState(() {
                          changeMessage = true;
                          textEditingController.text = chatMessages[
                                  chatMessages.length - 1 - messageOptionsIndex]
                              ['message'];
                        });
                      },
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
              clipBehavior: Clip.hardEdge,
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.zero),
              child: !usersProfilePics.containsKey(profileId)
                  ? Image.asset(
                      'assets/default_profile_picture.jpg',
                      fit: BoxFit.fitWidth,
                      height: screenHeight * 0.08,
                      //width: screenWidth * 0.06,
                    )
                  : Image.file(
                      usersProfilePics[profileId],
                      fit: BoxFit.fill,
                      height: screenHeight * 0.08,
                      //width: screenWidth * 0.16,
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
        changeMessage
            ? IconButton(
                onPressed: () {
                  setState(() {
                    changeMessage = false;
                  });
                  textEditingController.clear();
                  keyboardFocus.nextFocus();
                },
                icon: const Icon(Icons.remove_circle))
            : Container(),
        SizedBox(
          width: screenWidth * (changeMessage ? 0.65 : 0.8),
          height: screenHeight * 0.1,
          child: TextField(
            focusNode: keyboardFocus,
            controller: textEditingController,
            onChanged: (text) {
              setState(() {
                textEditingController.text = text;
              });
            },
          ),
        ),
        SizedBox(
          width: screenWidth * 0.03,
        ),
        SizedBox(
          width: screenWidth * 0.17,
          height: screenHeight * 0.1,
          child: ElevatedButton(
              style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)))),
              onPressed: () async {
                //change !internetIsOn to waiting for internet connection!
                if (!checkEmptyText(textEditingController.text) ||
                    !internetIsOn) return;
                if (sendMessagePressed) return;
                setState(() {
                  sendMessagePressed = true;
                });
                await handlePress().then(
                    (value) => setState(() => sendMessagePressed = false));
              },
              child: Icon(
                Icons.send,
                size: screenHeight * 0.05,
              )),
        )
      ],
    );
  }

  Future<void> handlePress() async {
    if (changeMessage) {
      await chat.changeMessage(
          [currentUsername!, profileId],
          chat.messages[chat.chatId].length - 1 - messageOptionsIndex,
          textEditingController.text,
          true);
      setState(() {
        changeMessage = false;
      });
      keyboardFocus.nextFocus();
    } else {
      await chat.addChat(profileId);
      await chat.sendMessage(
          [currentUsername!, profileId], textEditingController.text);
      await chat.getChat(chat.chatId);
    }

    textEditingController.clear();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    keyboardFocus.dispose();
    super.dispose();
  }
}
