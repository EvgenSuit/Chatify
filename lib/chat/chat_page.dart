import 'package:flutter/material.dart';
import 'package:metaballs/metaballs.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Row(),
        Expanded(child: Metaballs(child: Center(child: Text('Messages')),)),
        Row()
      ]),
    );
  }
}