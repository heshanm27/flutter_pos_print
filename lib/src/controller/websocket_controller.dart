import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

class WebSocketController extends GetxController{
  RxBool isConnected = false.obs;
  RxBool isConnecting = false.obs;
  RxString address = "".obs;
  RxInt connectionTimeOut = 5.obs;
  late IOWebSocketChannel channel;

  void webSocketConnect(String url,int? timeOut){
    debugPrint("Connecting to $url");
    isConnecting.value = true;
    address.value = url;
    if(timeOut != null){
      connectionTimeOut.value = timeOut;
    }
    update();
     channel = IOWebSocketChannel.connect(Uri.parse(url),connectTimeout: Duration(seconds: connectionTimeOut.value));

    channel.sink.add(
      jsonEncode(
        {
          "type": "subscribe",
          "channels": [
            {
              "name": "ticker",
              "product_ids": [
                "BTC-EUR",
              ]
            }
          ]
        },
      ),
    );

    /// Listen for all incoming data
    channel.stream.listen(
          (data) {
            isConnected.value = true;
            isConnecting.value = false;
        print(data);
      },
      onError: (error) {
        isConnected.value = false;
        isConnecting.value = false;
            print(error);},
    );
  }

  void disconnect(){
    channel.sink.close(
      1000,
      "I'm done",
    ).then((value) {

      isConnected.value = false;

      print("Closed");
    });
  }
}