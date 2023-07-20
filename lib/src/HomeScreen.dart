import 'package:flutter/material.dart';
import 'package:flutter_print/src/controller/print_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'components/printerDialog.dart';
import 'model/printer_map_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PrintController printController = Get.find<PrintController>();
    GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final ipController = TextEditingController();
    final portController = TextEditingController(text: "9001");
    final printerKeyController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("TCP/IP Printer"),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Flexible(
                                      flex: 2, child: Text("Printer Map Key: ")),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter Printer Map Key';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Printer Map Key',
                                      ),
                                      controller: printerKeyController,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Flexible(
                                      flex: 2, child: Text("IP Address: ")),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter ip address';
                                        }
                                        return null;
                                      },
                                      decoration: const InputDecoration(
                                        hintText: 'Enter IP Address',
                                      ),
                                      controller: ipController,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Flexible(
                                      flex: 2, child: Text("PORT: ")),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter port';
                                        }
                                        return null;
                                      },
                                      controller: portController,
                                      decoration: const InputDecoration(
                                        hintText: 'Enter PORT',
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              ElevatedButton(
                                  onPressed: () {
                                    if (formKey.currentState!.validate()) {
                                      printController.addTcpIpPrinter(
                                          printerKeyController.text,
                                          ipController.text,
                                          portController.text);
                                    }
                                  },
                                  child: const Text("Connect"))
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 50,
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black12,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Form(
                          child: Column(
                            children: [
                              const Text("WebSocket Connect"),
                              Row(
                                children: [
                                  const Text("URL: "),
                                  Flexible(
                                    child: TextFormField(
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Web Socket Url',
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              ElevatedButton(
                                  onPressed: () {},
                                  child: const Text("Connect"))
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const PrinterDialog();
                              });
                        },
                        child: const Text("Add Printer")),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton(onPressed: (){
                      printController.printTicketOnMultiDevice("invoice");
                    }, child: const Text("Print multi Test")),
                    // ElevatedButton(onPressed: (){
                    //   printController.saveSelectedPrinterMapToSharedPreferences(printController.selectedPrinterMap.value);
                    // }, child: const Text("Save List ")),
                    // ElevatedButton(onPressed: () async{
                    //   List<PrintMapModel> list = await printController.getSelectedPrinterMapFromSharedPreferences();
                    //   list.forEach((element) {
                    //     print(element.deviceName);
                    //   });
                    // }, child: const Text("Get List"))
                  ],
                ),
                const SizedBox(
                  height: 30,
                ),
                Obx(
                  () => SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Printer Key")),
                            DataColumn(label: Text("Device Name")),
                            DataColumn(label: Text("Device Status")),
                            DataColumn(label: Text("Device Action")),
                            DataColumn(label: Text("Action")),
                          ],
                          rows: printController.selectedPrinterMap.value
                              .map((e) => DataRow(cells: [
                                    DataCell(Text(e.key ?? ""), onTap: () {
                                      printController.selectedPrinterMap.value
                                          .remove(e);
                                    }),
                                    DataCell(

                                      Text(e.printer?.deviceName ?? "",maxLines: 1,overflow: TextOverflow.ellipsis,),
                                    ),
                                    DataCell(
                                      e.status == "Connecting"
                                          ? const SpinKitThreeBounce(
                                              color: Colors.grey,
                                              size: 12,
                                            )
                                          : Text(e.status ?? ""),
                                    ),
                                    DataCell(ElevatedButton(
                                        onPressed: () {
                                          printController.printCommand(e);
                                        },
                                        child: const Text("Test"))),
                                    DataCell(SingleChildScrollView(
                                      child: Row(
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                printController.connectOneDevice(e);
                                              },
                                              splashRadius: 10,
                                              icon: const Icon(
                                                Icons.refresh,
                                              )),
                                          IconButton(
                                              onPressed: () {
                                                printController.removeMapPrinter(e);
                                              },
                                              splashRadius: 10,
                                              icon: const Icon(
                                                Icons.delete,
                                              )),
                                        ],
                                      ),
                                    )),
                                  ]))
                              .toList()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
