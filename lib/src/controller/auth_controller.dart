


import 'dart:convert';

import 'package:flutter/cupertino.dart';

class AuthController {
  static const String _key = "O7sdHPml6zBaGgvjQQ/lNfD22ZvbJ6hP92PZ98P9dPlKk352xrHpYQvYzZ970qw0";


  static bool checkAuth(String? key)  {
    if(key == null){
      return false;
    }


    try {
      String parsedKey = utf8.decode(base64.decode(key));
      if (parsedKey == _key) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print('Base64 decoding error: $e');
      return false;
    }
  }

}