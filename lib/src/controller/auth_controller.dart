import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthController {

  static  final String? _key = dotenv.env['AUTH_KEY'];


  static bool checkAuth(String? key)  {


    debugPrint('key: ${key}');

    if(key == null){
      return false;
    }
    debugPrint('key: ${dotenv.env['AUTH_KEY']}');

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