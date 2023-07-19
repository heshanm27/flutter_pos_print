import 'package:get/get_navigation/src/routes/get_route.dart';

 import '../../flutterpritn.dart';
import '../HomeScreen.dart';

class AppRoutes {
  static const String home = '/';
  static const String print = '/print';
  static const String printSetting = '/printSetting';
  static List<GetPage> routes = [
    GetPage(name: home, page: () => const FlutterPRint()),
    GetPage(name: print, page: () => const HomeScreen()),
  ];
}