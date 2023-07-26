import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_print/src/components/windows_buttons.dart';
import '../misc/app_constants.dart';
import 'image_loader.dart';

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
                    child: Row(
                      children: [
                        const ImageLoader(url: "assets/winIcon.png",width: 20,height: 20),
                        const SizedBox(width: 10,),
                        Text(AppConstant.appName,style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Colors.white,
                        ),textAlign: TextAlign.left,),
                      ],
                    ),
                  ),
                ))),
            const WindowsButtons(),
          ],
        ),
      ),
    );
  }
}
