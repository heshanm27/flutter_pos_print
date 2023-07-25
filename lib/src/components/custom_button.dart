import 'package:flutter/material.dart';
import 'package:flutter_print/src/components/image_loader.dart';

class CustomButton extends StatelessWidget {
  final Function() onPressed;
  final String? icon;
  final String title;
  final bool isOutlined;
  final Color? iconColor;

  const CustomButton({
    required this.onPressed,
    required this.title,
    this.icon,
    this.isOutlined = false, // Default value is false, i.e., not outlined
    Key? key,
    this.iconColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: onPressed,

        style: isOutlined
            ? ButtonStyle(
                elevation:
                    MaterialStateProperty.all<double>(0),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    side: const BorderSide(
                        color: Colors.black), // Set the outline color
                  ),
                ),
              )
            : null, //
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8,horizontal:4 ),
          child: Row(
            children: [
              Text(title,style: TextStyle(
                color:isOutlined ? Colors.black :Colors.white
              ),),
              const SizedBox(
                width: 10,
              ),
              icon != null
                  ? ImageLoader(
                      url: icon ?? "",
                      height: 16,
                      width: 16,
                      color: iconColor,
                    )
                  : const SizedBox()
            ],
          ),
        ));
  }
}
