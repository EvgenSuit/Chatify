import 'package:flutter/material.dart';
import 'package:chatify/common/variables.dart';

class AppScreen extends StatelessWidget {
  const AppScreen({Key? key, required this.heightRatio}) : super(key: key);
  final double heightRatio; //moves the app name up

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color.fromARGB(255, 0, 0, 255), Colors.purple])),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chatify',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: screenHeight * heightRatio,
            ),
          ],
        )
      ],
    );
  }
}
