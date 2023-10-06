import 'package:chatify/chat/chats.dart';
import 'package:chatify/firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/auth_page.dart';
import 'chat/main_page.dart';
import 'auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:chatify/common/variables.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseAuth.instance.signOut();
  await GetStorage.init();

  prefs = await SharedPreferences.getInstance();
  externalStorageDir = await getExternalStorageDirectory();
  docDir = await getApplicationDocumentsDirectory();
  checkIfSignedIn();
  await handleCredentialsOnStartup(prefs!);
  runApp(const Chatify());
}

Future<void> handleCredentialsOnStartup(SharedPreferences prefs) async {
  //prefs.setBool('isSignedIn', false);
  final prefIsSignedIn = prefs.getBool('isSignedIn');
  if (prefIsSignedIn == null || !prefIsSignedIn) {
    checkIfSignedIn();
  } else {
    isSignedIn = prefIsSignedIn;
  }
  if (isSignedIn) {
    currentUsername = prefs.getString('currentUsername');
  }
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
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return MaterialApp(
      home: isSignedIn ? MainPage() : const AuthPage(),
    );
  }
}
