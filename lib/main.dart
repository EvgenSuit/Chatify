import 'package:chatify/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth.dart';
import 'chat/chats_page.dart';
import 'common/variables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  checkIfSignedIn();
  runApp(const Chatify());
}

class Chatify extends StatelessWidget {
  const Chatify({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: isSignedIn ? ChatsPage() : AuthPage(),
    );
  }
}
