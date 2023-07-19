import 'dart:convert';

import 'package:flutter_print/src/model/printer_model.dart';

PrintMapModel printMapModelFromJson(String str) => PrintMapModel.fromJson(json.decode(str));

String printMapModelToJson(PrintMapModel data) => json.encode(data.toJson());

class PrintMapModel {
  String? key;
  String? deviceName;
  bool? isConnected;
  String? status;
  PrinterModel? printer;
  PrintMapModel({
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
  );

  Map<String, dynamic> toJson() => {
    "key": key,
    "deviceName": deviceName,
    "isConnected": isConnected,
    "status": status,
  };
}