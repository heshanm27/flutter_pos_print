import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_print/src/components/image_loader.dart';
import 'package:flutter_print/src/components/printerDialog.dart';
import 'package:path/path.dart';

class CustomDropButton extends StatelessWidget {
  final Function() onPressed;
  final String? icon;
  final String title;
  final bool isOutlined;
  final Color? iconColor;

  const CustomDropButton({
    required this.onPressed,
    required this.title,
    this.icon,
    this.isOutlined = false, // Default value is false, i.e., not outlined
    Key? key,
    this.iconColor = Colors.white,
  }) : super(key: key);




  @override
  Widget build(BuildContext context) {
    callDialog(String printerType) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return PrinterDialog(printerType: printerType);
          });
    }

    void showPopupMenu(BuildContext context) async {
      final RenderBox button = context.findRenderObject() as RenderBox;
      final Offset offset = button.localToGlobal(Offset.zero);
      final Size buttonSize = button.size;

      final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      final Size overlaySize = overlay.size;

      final double screenHeight = MediaQuery.of(context).size.height;

      final double menuTop = offset.dy;
      final double menuBottom = screenHeight - menuTop;
      final double menuHeight = menuBottom - kToolbarHeight;

      final selectedValue =  await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(
          offset.dx,
          menuTop,
          offset.dx,
          menuTop + menuHeight,
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4)
        ),
        items: <PopupMenuEntry>[
          // Add your menu items here
          if (Platform.isAndroid || Platform.isIOS)
            PopupMenuItem(
              value: 'bluetooth',
              child: Text('Bluetooth Printer',style: TextStyle(color:Colors.black.withOpacity(0.7),fontSize: 16),),
            ),
          if (Platform.isAndroid || Platform.isIOS || Platform.isWindows)
            PopupMenuItem(
              value: 'network',
              child: Text('Network Printer',style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 16),),
            ),
          if (Platform.isAndroid || Platform.isWindows)
            PopupMenuItem(
              value: 'usb',
              child: Text('USB Printer',style: TextStyle(color: Colors.black.withOpacity(0.7),fontSize: 16),),
            ),
        ],
        elevation: 8,
      );

      // Handle the selected value (if needed)
      if (selectedValue != null) {
        callDialog(selectedValue);
        print('Selected option: $selectedValue');
      }
    }


    return ElevatedButton(
      onPressed: () {
        // if (isOutlined) {
          showPopupMenu(context);
        // } else {
        //   onPressed();
        // }
      },
      style: isOutlined
          ? ButtonStyle(
        elevation: MaterialStateProperty.all<double>(0),
        backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
        shape: MaterialStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4.0),
            side: const BorderSide(
                color: Colors.black), // Set the outline color
          ),
        ),
      )
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(color: isOutlined ? Colors.black : Colors.white),
            ),
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
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
