import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:get/get.dart';
import '../controller/print_controller.dart';
import '../model/printer_model.dart';

class PrinterDialog extends StatefulWidget {
  String printerType;
   PrinterDialog({required this.printerType,    super.key});

  @override
  State<PrinterDialog> createState() => _PrinterDialogState();
}

class _PrinterDialogState extends State<PrinterDialog> {

  TextEditingController printerKeyController = TextEditingController();
  late PrintController printController;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  PrinterType? selectedPrinterType;
  late PrinterModel selectedPrinter ;
  @override
  void initState() {
    printController = Get.find<PrintController>();
    selectedPrinterType  = getPrinterType(widget.printerType);
    selectedPrinter =printController.devices.isNotEmpty
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
        // height: Platform.isAndroid ? 400 :250,
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text("Add New Printer",style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold
              ),),

              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<PrinterType>(
                value:printController.defaultPrinterType,
                decoration:  InputDecoration(
                  prefixIcon: SizedBox(
                    height: 36,
                    width: 36,
                    child: Image.asset(
                        "assets/icons/printer.png"),
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
                      child: Text("Bluetooth",style: TextStyle(fontSize: 12)),
                    ),
                  if (Platform.isAndroid || Platform.isWindows)
                    const DropdownMenuItem(
                      value: PrinterType.usb,
                      child: Text("USB",style: TextStyle(fontSize: 12)),
                    ),
                  if (Platform.isAndroid || Platform.isIOS || Platform.isWindows)
                  const DropdownMenuItem(
                    value: PrinterType.network,
                    child: Text("Network",style: TextStyle(fontSize: 12)),
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
              Obx(
               ()=> Visibility(
                  visible: Platform.isAndroid ? true : false,
                  child: SwitchListTile.adaptive(
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
                ),
              ),
              Obx(
                ()=> Visibility(
                  visible:Platform.isAndroid ? true : false,
                  child: SwitchListTile.adaptive(
                    contentPadding:
                    const EdgeInsets.only(bottom: 20.0, left: 20),
                    title: const Text(
                      "Reconnect",
                      textAlign: TextAlign.start,
                    ),
                    value:  printController.reconnect.value ,
                    onChanged: (bool? value) {
                      printController.reconnect.value = value ?? false;
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  const Text("Printer Key"),
                  const SizedBox(
                    width: 12,
                  ),
                  Flexible(
                    child: TextFormField(
                      controller: printerKeyController,
                      maxLines: 1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter printer key';
                        }
                        return null;
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Obx(
                  ()=> printController.devices.isEmpty ?const Text("No Devices Detected")  : Row(
                  children: [
                    const Text("Select Printer"),
                    const SizedBox(
                      width: 12,),
                    Flexible(
                      child: DropdownButtonFormField<PrinterModel>(
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
                      ),
                    )
                  ],
                ),
              ),

              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [  Directionality(
                  textDirection: TextDirection.rtl,
                  child: ElevatedButton.icon(
                      onPressed: () {
                        printController.scan();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text("Refresh Devices")),
                ),
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: ElevatedButton.icon(onPressed: (){
                      if(formKey.currentState!.validate()){
                        if(selectedPrinter.deviceName == null){
                          Get.snackbar("Error", "Please select printer");
                          return;
                        }
                        printController.mapPrinterToKey(printerKeyController.text, selectedPrinter);
                        Get.back();
                      }
                    }, icon: const Icon(Icons.save), label: const Text("Save")  ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }


  PrinterType getPrinterType(String type){
    switch(type){
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
