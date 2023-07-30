import 'package:flutter/material.dart';

int numShowedSnackbars = 0;
void showSnackBar({required BuildContext context, required String content}) {
  if (numShowedSnackbars != 0) return;
  numShowedSnackbars++;
  final snackBar = SnackBar(
    content: Text(content),
    duration: const Duration(milliseconds: 1300),
  );

  ScaffoldMessenger.of(context)
      .showSnackBar(snackBar)
      .closed
      .then((value) => numShowedSnackbars = 0);
}
