import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_print/src/controller/print_controller.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

import '../model/websocket_model.dart';
import '../model/websocket_response_model.dart';
import 'auth_controller.dart';

class WebSocketController extends GetxController {
  final int port = 12864;
  final String ipAddress = "127.0.0.1";

  RxBool isConnected = false.obs;
  RxBool isConnecting = false.obs;
  RxString address = "".obs;
  RxInt connectionTimeOut = 5.obs;
  late IOWebSocketChannel channel;
  late HttpServer server;
  PrintController printController = Get.find<PrintController>();

  @override
  void onInit() {
    super.onInit();
    _webSocketServerUp();
  }

  @override
  void dispose() {
    channel.sink.close();
    server.close(
      force: true,
    );
    super.dispose();
  }

  // Web Socket Server Up In Localhost
  void _webSocketServerUp() async {
    try {
      server = await HttpServer.bind(ipAddress, port);
      if (server == null) {
        throw SocketException("Port $port is already in use.");
      }
      debugPrint(
          'WebSocket server is running on port ${server.address.address}${server.port}');
      isConnected.value = true;
      server.listen((request) {
          if (WebSocketTransformer.isUpgradeRequest(request)) {
            handleWebSocket(request);
          }
      });
      channel =
          IOWebSocketChannel.connect('ws://$ipAddress:${port.toString()}');
    } catch (e) {
      if (e is SocketException) {
        Get.defaultDialog(title: "Error", middleText: e.message);
      } else {
        debugPrint('Error starting WebSocket server: $e');
      }
    }
  }

  // Handle WebSocket connection.
  void handleWebSocket(HttpRequest request) {
    WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
      webSocket.listen((data) async {
        try {
          if(AuthController.checkAuth(request.headers.value('auth')) == true) {
            WebSocketModel webSocketModel =
            WebSocketModel.fromJson(jsonDecode(data));
            WebSocketResponseModel response =
            await printController.webSocketPrintCommand(webSocketModel);
            webSocket.add(response.toJson().toString());
          }else{
          throw Exception("Authentication Failed");
          }
        } catch (e) {
          webSocket.add('Error: $e');
        }
      }, onError: (error) {
        webSocket.add('Error: $error');
        // print('Error: $error');
      }, onDone: () {
        webSocket.add('Disconnected!');
        print('WebSocket disconnected!');
      });
    }).catchError((error) {
      
      print('Error upgrading to WebSocket: $error');
    });
  }

// void webSocketConnect(String url,int? timeOut){
//   debugPrint("Connecting to $url");
//   isConnecting.value = true;
//   address.value = url;
//   if(timeOut != null){
//     connectionTimeOut.value = timeOut;
//   }
//   update();
//    channel = IOWebSocketChannel.connect(Uri.parse(url),connectTimeout: Duration(seconds: connectionTimeOut.value));
//
//   channel.sink.add(
//     jsonEncode(
//       {
//         "type": "subscribe",
//         "channels": [
//           {
//             "name": "ticker",
//             "product_ids": [
//               "BTC-EUR",
//             ]
//           }
//         ]
//       },
//     ),
//   );
//
//   /// Listen for all incoming data
//   channel.stream.listen(
//         (data) {
//           isConnected.value = true;
//           isConnecting.value = false;
//       print(data);
//     },
//     onError: (error) {
//       isConnected.value = false;
//       isConnecting.value = false;
//           print(error);},
//   );
// }

// void disconnect(){
//   channel.sink.close(
//     1000,
//     "I'm done",
//   ).then((value) {
//
//     isConnected.value = false;
//
//     print("Closed");
//   });
// }

// Web Socket Server Up In Localhost
}
