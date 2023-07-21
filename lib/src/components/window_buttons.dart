import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowButtons extends StatelessWidget {
  const WindowButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: WindowButtonColors(iconNormal: Colors.black54, mouseOver: Colors.black54, mouseDown: Colors.black54)),
        // MaximizeWindowButton(colors: WindowButtonColors(iconNormal: Colors.black54, mouseOver: Colors.white, mouseDown: Colors.white)),
        CloseWindowButton(colors: WindowButtonColors(iconNormal: Colors.black54, mouseOver: Colors.red, mouseDown: Colors.red),onPressed: () => appWindow.hide()),
      ],
    );
  }
}
