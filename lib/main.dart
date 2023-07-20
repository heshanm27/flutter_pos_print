 import 'dart:io';
 import 'package:flutter/material.dart';
 import 'package:flutter/services.dart';
 import 'package:flutter_print/src/controller/print_controller.dart';
 import 'package:flutter_print/src/routes/routes.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:permission_handler/permission_handler.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isWindows){
    doWhenWindowReady(() {
      final win = appWindow;
      const initialSize = Size(800, 600);
      win.minSize = initialSize;
      win.maxSize = initialSize;
      win.size = initialSize;
      win.alignment = Alignment.center;
      win.title = "CineSync Printer Manager";
      win.show();
    });
  }

  // if(Platform.isWindows){
  //   const MethodChannel('window_events').setMethodCallHandler((call) async {
  //     switch (call.method) {
  //       case 'onWindowClose':
  //         appWindow.hide();
  //         break;
  //     }
  //   });
  // }

  if(Platform.isAndroid){
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request();
  }
  runApp(const MyApp());

  Get.put(PrintController());

}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();


}

class _MyAppState extends State<MyApp> {

  //
  // @override
  // void initState() {
  //
  //   initializeWindowManager();
  //   super.initState();
  // }
  // Future<void> initializeWindowManager() async {
  //   const platform = MethodChannel('window_events');
  //   platform.setMethodCallHandler(_handleMethod);
  // }
  //
  // Future<dynamic> _handleMethod(MethodCall call) async {
  //   switch (call.method) {
  //     case 'onWindowClose':
  //       initSystemTray();
  //       break;
  //     default:
  //       throw UnimplementedError('${call.method} not implemented.');
  //   }
  // }


  // Future<void> initSystemTray() async {
  //   String path =
  //   Platform.isWindows ? 'assets/Picture1.png' : 'assets/Picture1.png';
  //
  //   final AppWindow appWindow = AppWindow();
  //   final SystemTray systemTray = SystemTray();
  //
  //   // We first init the systray menu
  //   await systemTray.initSystemTray(
  //     title: "system tray",
  //     iconPath: path,
  //   );
  //
  //   // create context menu
  //   final Menu menu = Menu();
  //   await menu.buildFrom([
  //     MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
  //     MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
  //     MenuItemLabel(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
  //   ]);
  //
  //   // set context menu
  //   await systemTray.setContextMenu(menu);
  //
  //   // handle system tray event
  //   systemTray.registerSystemTrayEventHandler((eventName) {
  //     debugPrint("eventName: $eventName");
  //     if (eventName == kSystemTrayEventClick) {
  //       Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
  //     } else if (eventName == kSystemTrayEventRightClick) {
  //       Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
  //     }
  //   });
  // }
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CineSync Printer Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
     initialRoute: AppRoutes.print,
     getPages: AppRoutes.routes,
    );
  }
}

