import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';

class PrinterModel {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;
  PrinterType typePrinter;
  bool? state;
  bool? isDefault;

  PrinterModel(
      {
         this.id,
        this.deviceName,
        this.address,
        this.port,
        this.state,
        this.vendorId,
        this.productId,
        this.typePrinter = PrinterType.bluetooth,
        this.isBle = false,
        bool? isDefault
      });

  factory PrinterModel.fromJson(Map<String, dynamic> json) {
    return PrinterModel(
      id: json["id"],
      deviceName: json["deviceName"],
      address: json["address"],
      port: json["port"],
      state: json["state"],
      vendorId: json["vendorId"],
      productId: json["productId"],
      typePrinter: PrinterType.values[json["typePrinter"]],
      isBle: json["isBle"],
      isDefault: json["isDefault"],
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "deviceName": deviceName,
    "address": address,
    "port": port,
    "state": state,
    "vendorId": vendorId,
    "productId": productId,
    "typePrinter": typePrinter.index,
    "isBle": isBle,
    "isDefault": isDefault,
  };

}
