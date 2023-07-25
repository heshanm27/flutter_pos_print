import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
  await dotenv.load(fileName: ".env");

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
      win.title = "CINESync Printer Manager";
      win.show();
    });
  }

  Get.put(PrintController());
  Get.put(WebSocketController());
}

String getTrayImagePath(String imageName) {
  return Platform.isWindows ? 'assets/winIcon.ico' : 'assets/winIcon.png';
}

String getImagePath(String imageName) {
  return Platform.isWindows ? 'assets/winIcon.ico' : 'assets/winIcon.png';
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
        appWindow.hide();
        return false;
      });
    }
  }

  Future<void> initSystemTray() async {
    String path =
        Platform.isWindows ? 'assets/winIcon.ico' : 'assets/winIcon.png';

    final AppWindow appWindow = AppWindow();
    final SystemTray systemTray = SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "CINESync Printer Manager",
      toolTip: "CINESync Printer Manager",
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

    MaterialColor customSwatch = const MaterialColor(
      0xFF000000, // Primary color value (black in this case)
      <int, Color>{
        // Define the shades of the primary color
        50: Color(0xFFE0E0E0),
        100: Color(0xFFB3B3B3),
        200: Color(0xFF808080),
        300: Color(0xFF4D4D4D),
        400: Color(0xFF262626),
        500: Color(0xFF000000),
        600: Color(0xFF000000),
        700: Color(0xFF000000),
        800: Color(0xFF000000),
        900: Color(0xFF000000),
      },
    );
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CINESync Printer Manager',
      theme: ThemeData(
        primarySwatch: customSwatch,
      ),
      initialRoute: AppRoutes.print,
      getPages: AppRoutes.routes,
    );
  }
}
