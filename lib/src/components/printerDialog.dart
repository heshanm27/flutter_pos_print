import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import '../controller/print_controller.dart';
import '../model/printer_model.dart';
import 'custom_button.dart';

class PrinterDialog extends StatefulWidget {
  String printerType;

  PrinterDialog({required this.printerType, super.key});

  @override
  State<PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<PrinterDialog> {
  TextEditingController printerKeyController = TextEditingController();
  TextEditingController ipAddressController = TextEditingController();
  TextEditingController portController = TextEditingController();
  late PrintController printController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late PrinterModel selectedPrinter;

  @override
  void initState() {
    printController = Get.find<PrintController>();
    selectedPrinter = printController.devices.isNotEmpty
        ? printController.devices.first
        : PrinterModel();
    printController.refreshScan(getPrinterType(widget.printerType));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        height: Platform.isWindows ? 480 : double.infinity,
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add New Printer",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<PrinterType>(
                value: printController.defaultPrinterType,
                decoration: InputDecoration(
                  prefixIcon: SizedBox(
                    height: 36,
                    width: 36,
                    child: Image.asset("assets/icons/printer.png"),
                  ),
                  labelText: "Type Printer Device",
                  labelStyle: const TextStyle(fontSize: 16.0),
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                items: <DropdownMenuItem<PrinterType>>[
                  if (Platform.isAndroid || Platform.isIOS)
                    const DropdownMenuItem(
                      value: PrinterType.bluetooth,
                      child: Text("Bluetooth", style: TextStyle(fontSize: 12)),
                    ),
                  if (Platform.isAndroid || Platform.isWindows)
                    const DropdownMenuItem(
                      value: PrinterType.usb,
                      child: Text("USB", style: TextStyle(fontSize: 12)),
                    ),
                  if (Platform.isAndroid ||
                      Platform.isIOS ||
                      Platform.isWindows)
                    const DropdownMenuItem(
                      value: PrinterType.network,
                      child: Text("Network", style: TextStyle(fontSize: 12)),
                    ),
                ],
                onChanged: (PrinterType? value) {
                  setState(() {
                    debugPrint("value $value");
                    if (value != null) {
                      printController.defaultPrinterType = value;
                      printController.refreshScan(value);
                    }
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Obx(
                () => Visibility(
                  visible: Platform.isAndroid ? true : false,
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding:
                            const EdgeInsets.only(bottom: 20.0, left: 20),
                        title: const Text(
                          "This device supports ble (low energy)",
                          textAlign: TextAlign.start,
                        ),
                        value: printController.isBle.value,
                        onChanged: (bool? value) {
                          printController.isBle.value = value ?? false;
                        },
                      ),
                      SwitchListTile.adaptive(
                        contentPadding:
                            const EdgeInsets.only(bottom: 20.0, left: 20),
                        title: const Text(
                          "Reconnect",
                          textAlign: TextAlign.start,
                        ),
                        value: printController.reconnect.value,
                        onChanged: (bool? value) {
                          printController.reconnect.value = value ?? false;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Printer Key *"),
                  const SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    controller: printerKeyController,
                    decoration: const InputDecoration(
                      focusedBorder: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(),
                      focusedErrorBorder: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(),
                    ),
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter printer key';
                      }
                      return null;
                    },
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Obx(
                () => printController.devices.isEmpty
                    ? Visibility(
                        visible: Platform.isAndroid || Platform.isIOS,
                        child:  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                text: 'Select Printer ',
                                style: DefaultTextStyle.of(context).style, // You can use the default text style or define your own.
                                children: const [
                                  TextSpan(
                                    text: '*',
                                    style: TextStyle(
                                      color: Colors.orange, // Change this to the desired color for the asterisk
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 12,
                            ),
                            const Text("No Devices Detected"),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Select Printer ',
                              style: DefaultTextStyle.of(context).style, // You can use the default text style or define your own.
                              children: const [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.orange, // Change this to the desired color for the asterisk
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          DropdownButtonFormField<PrinterModel>(
                            decoration: InputDecoration(
                              prefixIcon: SizedBox(
                                height: 36,
                                width: 36,
                                child: Image.asset("assets/icons/printer.png"),
                              ),
                              labelText: "Select Printer",
                              labelStyle: const TextStyle(fontSize: 16.0),
                              focusedBorder: InputBorder.none,
                              enabledBorder: const OutlineInputBorder(),
                            ),
                            value: printController.devices.isNotEmpty
                                ? printController.devices.first
                                : null,
                            items: printController.devices
                                .map((device) => DropdownMenuItem<PrinterModel>(
                                      value: device,
                                      child: Text(device.deviceName ?? ""),
                                    ))
                                .toList(),
                            onChanged: (selectedDevice) {
                              selectedPrinter = selectedDevice!;
                            },
                          )
                        ],
                      ),
              ),
              const SizedBox(
                height: 12,
              ),
              Visibility(
                  visible: printController.defaultPrinterType ==
                          PrinterType.network &&
                      Platform.isWindows,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          RichText(
                            text: TextSpan(
                              text: 'IP Address  ',
                              style: DefaultTextStyle.of(context).style, // You can use the default text style or define your own.
                              children: const [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.orange, // Change this to the desired color for the asterisk
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            controller: ipAddressController,
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(),
                              focusedErrorBorder: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(),
                            ),
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter ip address';
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'PORT ',
                              style: DefaultTextStyle.of(context).style, // You can use the default text style or define your own.
                              children: const [
                                TextSpan(
                                  text: '*',
                                  style: TextStyle(
                                    color: Colors.orange, // Change this to the desired color for the asterisk
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          TextFormField(
                            controller: portController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: const InputDecoration(
                              focusedBorder: OutlineInputBorder(),
                              errorBorder: OutlineInputBorder(),
                              focusedErrorBorder: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(),
                            ),
                            maxLines: 1,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter PORT';
                              }
                              return null;
                            },
                          )
                        ],
                      ),
                    ],
                  )),

              Spacer(),
              Row(
                mainAxisAlignment:
                    printController.defaultPrinterType != PrinterType.network &&
                            Platform.isWindows
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.start,
                children: [
                  Visibility(
                    visible: printController.defaultPrinterType !=
                            PrinterType.network &&
                        Platform.isWindows,
                    child: CustomButton(
                        onPressed: () {
                          printController.scan();
                        },
                        icon: "assets/icons/refresh.png",
                        isOutlined: true,
                        iconColor: Colors.black,
                        title: "Refresh Devices"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                          onPressed: () {
                            Get.back();
                          },
                          isOutlined: true,
                          iconColor: Colors.black,
                          title: "Cancel"),
                      const SizedBox(
                        width: 12,
                      ),
                      CustomButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (printController.defaultPrinterType ==
                                      PrinterType.network &&
                                  Platform.isWindows) {
                                printController.addTcpIpPrinter(
                                    printerKeyController.text,
                                    ipAddressController.text,
                                    portController.text);
                                Get.back();
                                return;
                              } else {
                                if (selectedPrinter.deviceName == null) {
                                  Get.snackbar(
                                      "Error", "Please select printer");
                                  return;
                                }
                                printController.mapPrinterToKey(
                                    printerKeyController.text, selectedPrinter);
                                Get.back();
                              }
                            }
                          },
                          isOutlined: false,
                          iconColor: Colors.black,
                          title: "Save"),
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  PrinterType getPrinterType(String type) {
    switch (type) {
      case "bluetooth":
        return PrinterType.bluetooth;
      case "usb":
        return PrinterType.usb;
      case "network":
        return PrinterType.network;
      default:
        return PrinterType.usb;
    }
  }
}
