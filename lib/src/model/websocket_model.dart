import 'dart:convert';

WebSocketModel webSocketModelFromJson(String str) => WebSocketModel.fromJson(json.decode(str));

String webSocketModelToJson(WebSocketModel data) => json.encode(data.toJson());

class WebSocketModel {
  String? printerKey;
  String? data;
  String? message;
  String? logo;
  String? paperSize;
  String? qrUrl;

  WebSocketModel({
    this.printerKey,
    this.data,
    this.message,
    this.logo,
    this.qrUrl,
    this.paperSize

  });

  factory WebSocketModel.fromJson(Map<String, dynamic> json) => WebSocketModel(
    printerKey: json["printerKey"],
    data: json["data"],
    message: json["message"],
    logo: json["logo"],
    qrUrl: json["qrUrl"],
    paperSize: json["paperSize"],
  );

  Map<String, dynamic> toJson() => {
    "printerKey": printerKey,
    "data": data,
    "message": message,
    "logo": logo,
    "qrUrl": qrUrl,
    "paperSize": paperSize,
  };
}
