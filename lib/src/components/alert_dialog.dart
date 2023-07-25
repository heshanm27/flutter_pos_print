import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'custom_button.dart';

class CustomAlert extends StatelessWidget {
  final String title;
  final String message;
  final String actionBtnTitle;
  final Function() onActionBtnPressed;
  const CustomAlert({super.key, required this.title, required this.message, required this.actionBtnTitle, required this.onActionBtnPressed});
  @override
  Widget build(BuildContext context) {
    return   BackdropFilter(
        filter: ColorFilter.mode(
          Colors.black, BlendMode.srcOver),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 250,
            width: 375,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    child: Icon(Icons.add_alert,color: Colors.redAccent),
                  )
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                  CustomButton(
                    title: 'Save',

                    onPressed:onActionBtnPressed
                  ),

                  const SizedBox(
                    width: 10,
                  ),
                  CustomButton(
                    title: 'Cancel',
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ]),
              ],
            ),
          ),
        ));
  }
}