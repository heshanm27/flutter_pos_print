import 'dart:convert';

import 'package:flutter_print/src/model/printer_model.dart';

PrintMapModel printMapModelFromJson(String str) => PrintMapModel.fromJson(json.decode(str));

String printMapModelToJson(PrintMapModel data) => json.encode(data.toJson());

class PrintMapModel {
  int mapId;
  String? key;
  String? deviceName;
  bool? isConnected;
  String? status;
  PrinterModel? printer;
  PrintMapModel({
    required this.mapId,
    this.key,
    this.deviceName,
    this.isConnected,
    this.status = "Disconnected",
    this.printer,
  });

  factory PrintMapModel.fromJson(Map<String, dynamic> json) => PrintMapModel(
    key: json["key"],
    deviceName: json["deviceName"],
    isConnected: json["isConnected"],
    status: json["status"],
    mapId: json['mapId'],
    printer: json['printer'] != null ? PrinterModel.fromJson(json['printer']) : null,
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "deviceName": deviceName,
    "isConnected": isConnected,
    "status": status,
    "mapId": mapId,
    "printer": printer?.toJson(),
  };
}