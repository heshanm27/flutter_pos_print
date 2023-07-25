import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowsButtons extends StatelessWidget {
  const WindowsButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: WindowButtonColors(iconNormal: Colors.white60, mouseOver: Colors.white38, mouseDown: Theme.of(context).primaryColor.withOpacity(0.5))),
        // MaximizeWindowButton(colors: WindowButtonColors(iconNormal: Colors.black54, mouseOver: Colors.white, mouseDown: Colors.white)),
        CloseWindowButton(colors: WindowButtonColors(iconNormal: Colors.white60, mouseOver: Colors.red, mouseDown: Colors.red),onPressed: () => appWindow.hide()),
      ],
    );
  }
}
