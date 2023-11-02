import 'dart:convert';

class WebSocketModel {
  String? printerKey;
  List<dynamic>? data;
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
    this.paperSize,
  });

  factory WebSocketModel.fromJson(Map<String, dynamic> json) {
    return WebSocketModel(
      printerKey: json["printerKey"],
      data: json["data"] != null ? List<dynamic>.from(json["data"]) : null,
      message: json["message"],
      logo: json["logo"],
      qrUrl: json["qrUrl"],
      paperSize: json["paperSize"],
    );
  }

  Map<String, dynamic> toJson() => {
    "printerKey": printerKey,
    "data": data,
    "message": message,
    "logo": logo,
    "qrUrl": qrUrl,
    "paperSize": paperSize,
  };
}
