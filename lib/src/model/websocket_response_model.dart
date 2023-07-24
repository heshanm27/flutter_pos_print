// To parse this JSON data, do
//
//     final webSocketResponseModel = webSocketResponseModelFromJson(jsonString);

import 'dart:convert';

WebSocketResponseModel webSocketResponseModelFromJson(String str) => WebSocketResponseModel.fromJson(json.decode(str));

String webSocketResponseModelToJson(WebSocketResponseModel data) => json.encode(data.toJson());

class WebSocketResponseModel {
  bool? status;
  String? message;

  WebSocketResponseModel({
    this.status,
    this.message,
  });

  factory WebSocketResponseModel.fromJson(Map<String, dynamic> json) => WebSocketResponseModel(
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
  };
}
