import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

double screenHeight = 0;
double screenWidth = 0;
ValueNotifier<String> authErrorMessage = ValueNotifier<String>('');
String errorMessage = '';
bool internetIsOn = false;
String? currentUsername = '';
SharedPreferences? prefs;
File? some;
Directory? externalStorageDir;
Directory? docDir;
final double backButtonSize = screenHeight*0.05;