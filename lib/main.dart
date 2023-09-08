import 'package:chatify/firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'auth/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/auth.dart';
import 'package:chatify/common/variables.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  checkIfSignedIn();
  runApp(const Chatify());
}

class Chatify extends StatefulWidget {
  const Chatify({Key? key}) : super(key: key);

  @override
  State<Chatify> createState() => _ChatifyState();
}

class _ChatifyState extends State<Chatify> {
  @override
  void initState() {
    super.initState();
    Connectivity().checkConnectivity().then((value) {
      if (value != ConnectivityResult.mobile &&
          value != ConnectivityResult.wifi) {
        authErrorMessage.value = 'No internet connection';
        internetIsOn = false;
      } else {
        internetIsOn = true;
      }
    });

    Connectivity().onConnectivityChanged.listen((event) {
      print(event);
      if (event != ConnectivityResult.mobile &&
          event != ConnectivityResult.wifi) {
        authErrorMessage.value = 'No internet connection';
        internetIsOn = false;
      } else if (authErrorMessage.value == 'No internet connection') {
        authErrorMessage.value = 'Internet connection restored';
        internetIsOn = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthPage(),
    );
  }
}
