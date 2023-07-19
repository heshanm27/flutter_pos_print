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
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    PrinterModel selectedPrinter = printController.devices.isNotEmpty
        ? printController.devices.first
        : PrinterModel();
    return Dialog(
      child: Container(
        width: 400,
        height: 250,
        padding: const EdgeInsets.all(12),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Text("Select And Map Printer"),
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
              Row(
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
                        // Add your logic here for when the dropdown value changes.
                      },
                    ),
                  )
                ],
              ),

              const Spacer(),
              ElevatedButton(onPressed: (){
                if(formKey.currentState!.validate()){
                  printController.mapPrinterToKey(printerKeyController.text, selectedPrinter);
                  Get.back();
                }
              }, child: const Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}
