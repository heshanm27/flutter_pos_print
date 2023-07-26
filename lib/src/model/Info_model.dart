import 'dart:convert';

import 'package:flutter/material.dart';

class InfoModel {
  String title;
  String? value;
  Widget? widget;

  InfoModel({
    required this.title,
     this.value,
     this.widget,
  });

}
