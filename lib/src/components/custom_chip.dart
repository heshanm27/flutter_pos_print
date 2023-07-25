import 'package:flutter/material.dart';

class CustomChip extends StatelessWidget {

  Color? bgColor;
  String status;
  IconData? icon;
  Color? iconColor;
   CustomChip({required this.status,icon = Icons.circle,this.iconColor =Colors.black12,this.bgColor =Colors.black12, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(status,style:const TextStyle(
          color: Colors.green
      )),
      backgroundColor: Colors.greenAccent.withOpacity(0.5),
      avatar: const CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 12,
        child: Icon(
          Icons.circle,
          color: Colors.green,
          size: 10,
        ),
      ),
    );
  }
}
