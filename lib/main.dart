import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_print/src/controller/print_controller.dart';
import 'package:flutter_print/src/controller/websocket_controller.dart';
import 'package:flutter_print/src/routes/routes.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:get/get.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:system_tray/system_tray.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  if (Platform.isAndroid) {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.nearbyWifiDevices,
    ].request();
  }
  runApp(const MyApp());
  if (Platform.isWindows) {
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

  Get.put(PrintController());
  Get.put(WebSocketController());
}

String getTrayImagePath(String imageName) {
  return Platform.isWindows ? 'assets/Picture1.png' : 'assets/Picture1.png';
}

String getImagePath(String imageName) {
  return Platform.isWindows ? 'assets/Picture1.png' : 'assets/Picture1.png';
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    if (Platform.isWindows) {
      initSystemTray();
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        print("FlutterWindowClose.setWindowShouldCloseHandler");
        appWindow.hide();
        return false;
      });
    }
  }

  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? 'assets/Picture1.ico' : 'assets/Picture1.png';

    final AppWindow appWindow = AppWindow();
    final SystemTray systemTray = SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "system tray",
      toolTip: "system tray tooltip",
      iconPath: path,
    );
    // Modified method to handle application exit
    void exitApp() {
      // Clean up any resources or save data if needed before closing the app

      // Allow the window to close
      FlutterWindowClose.setWindowShouldCloseHandler(null);

      // Close the window
      appWindow.close();
    }
    // create context menu
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
      MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) =>exitApp()),
    ]);


    // set context menu
    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CineSync Printer Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: AppRoutes.print,
      getPages: AppRoutes.routes,
    );
  }
}
