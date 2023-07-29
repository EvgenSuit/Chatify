import 'package:chatify/auth/auth.dart';
import 'package:chatify/chat/chats_page.dart';
import 'package:flutter/material.dart';
import 'package:chatify/common/app_screen.dart';
import 'package:chatify/common/variables.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    super.initState();
  }

  void showSnackBar({required BuildContext context, required String content}) {
    final snackBar = SnackBar(
      content: Text(content),
      duration: const Duration(milliseconds: 1300),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  bool hidePassword = true;
  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(children: [
        AppScreen(
          heightRatio: 0.5,
        ),
        Padding(padding: EdgeInsets.all(screenWidth * 0.1), child: authFields())
      ]),
    );
  }

  Widget authFields() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextField(
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Username'),
          onChanged: (text) => setState(() {
            username = text;
          }),
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        TextField(
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Email'),
          onChanged: (text) => setState(() {
            email = text;
          }),
        ),
        SizedBox(
          height: screenHeight * 0.05,
        ),
        TextField(
          style: const TextStyle(color: Colors.white),
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: password.isNotEmpty
                  ? IconButton(
                      onPressed: () => setState(() {
                            hidePassword = !hidePassword;
                          }),
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: !hidePassword ? Colors.green : Colors.red,
                      ))
                  : null),
          onChanged: (text) => setState(() {
            password = text;
          }),
          obscureText: hidePassword,
        ),
        SizedBox(
          height: screenHeight * 0.07,
        ),
        authButtons(),
        SizedBox(height: screenHeight * 0.01)
      ],
    );
  }

  Widget authButtons() {
    List<String> ids = ['Sign In', 'Sign Up'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [for (String id in ids) baseAuthButton(id: id)],
    );
  }

  ElevatedButton baseAuthButton({required String id}) {
    return ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
            fixedSize: MaterialStateProperty.all(
                Size(screenWidth * 0.3, screenHeight * 0.08))),
        onPressed: () async {
          await auth(id: id);
          if (errorMessage == '') {
            if (id == 'Sign Up') {
              showSnackBar(context: context, content: 'User has been created');
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => ChatsPage()));
            }
          } else {
            showSnackBar(context: context, content: errorMessage);
          }
        },
        child: Text(
          id,
          style: const TextStyle(color: Colors.white),
        ));
  }
}
