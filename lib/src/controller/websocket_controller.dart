import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketController extends GetxController{
  static const int port = 8000;
  static const String ipAddress = "127.0.0.1";

  RxBool isConnected = false.obs;
  RxBool isConnecting = false.obs;
  RxString address = "".obs;
  RxInt connectionTimeOut = 5.obs;
  late IOWebSocketChannel channel;

  @override
  void onInit() {
    super.onInit();
    webSocketServerUp();

  }


  // Web Socket Server Up In Localhost
  void webSocketServerUp() async {
    try {
      final server = await HttpServer.bind(ipAddress, port);
      if(server != null){
        throw const SocketException("Port 8000 is already in use.");
      }
      debugPrint('WebSocket server is running on port ${server.address.address}${server.port}');
      server.listen((request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          handleWebSocket(request);
        }
      });
      channel = IOWebSocketChannel.connect('ws://$ipAddress:${port.toString()}');
    }catch(e){
      if (e is SocketException) {
        Get.defaultDialog(title: "Error",middleText: e.message);
      } else {
        debugPrint('Error starting WebSocket server: $e');
      }
    }
  }

  // Handle WebSocket connection.
  void handleWebSocket(HttpRequest request) {
    WebSocketTransformer.upgrade(request).then((WebSocket webSocket) {
      // You can handle WebSocket events here.
      webSocket.listen((data) {
        print('Received data: $data');
        // Handle incoming messages here.
        webSocket.add('Message received: $data');
      }, onError: (error) {
        print('Error: $error');
      }, onDone: () {
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