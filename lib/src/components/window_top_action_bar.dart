import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_print/src/components/windows_buttons.dart';

class WindowsTopActionBar extends StatelessWidget {
  const WindowsTopActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      child: WindowTitleBarBox(
        child: Row(
          children: [
            Expanded(child: WindowTitleBarBox(
                child: MoveWindow(
                  child:  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 5, 0, 0),
                    child: Text("CineSync Printer Manager",style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                    ),textAlign: TextAlign.left,),
                  ),
                ))),
            const WindowsButtons(),
          ],
        ),
      ),
    );
  }
}
