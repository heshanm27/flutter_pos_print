import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/print_controller.dart';
import '../model/printer_model.dart';

class PrinterDialog extends StatelessWidget {
  const PrinterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController printerKeyController = TextEditingController();
    PrintController printController = Get.find<PrintController>();


    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Text("Printer Key"),
              TextFormField(
                controller:printerKeyController,

              )
            ],
          ),
          Row(
            children: [
              const Text("Select Printer"),
              // DropdownButtonFormField<PrinterModel>(
              //   value: defaultPrinterType,
              //   decoration: const InputDecoration(
              //     prefixIcon: Icon(
              //       Icons.print,
              //       size: 24,
              //     ),
              //     labelText: "Type Printer Device",
              //     labelStyle: TextStyle(fontSize: 18.0),
              //     focusedBorder: InputBorder.none,
              //     enabledBorder: InputBorder.none,
              //   ),
              //   items: printController.devices.value
              //       .map((e) => DropdownMenuItem<PrinterModel>(
              //             value: e,
              //             child: Text(e.deviceName ?? ""),
              //           ))
              //       .toList(),
              //   onChanged: (PrinterModel? value) {
              //
              //   },
              // ),
            ],
          )
        ],
      ),
    );
  }
}
