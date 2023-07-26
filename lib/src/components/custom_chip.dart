import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {

  Color? bgColor;
  String status;
  IconData? icon;
  Color? iconColor;
   CustomChip({required this.status,icon = Icons.circle,this.iconColor =Colors.black54,this.bgColor =Colors.black, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status,style: TextStyle(
          color: iconColor,
      )),
      backgroundColor: bgColor?.withOpacity(0.3),
      avatar:  CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 12,
        child: Icon(
          Icons.circle,
          color: iconColor,
          size: 10,
        ),
      ),
    );
  }
}
