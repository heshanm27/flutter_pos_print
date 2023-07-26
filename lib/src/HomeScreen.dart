import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_print/src/components/custom_button.dart';
import 'package:flutter_print/src/components/info_components.dart';
import 'package:flutter_print/src/controller/print_controller.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'components/custom_chip.dart';
import 'components/drop_down_btn.dart';
import 'components/printerDialog.dart';
import 'components/window_top_action_bar.dart';
import 'components/windows_buttons.dart';
import 'controller/websocket_controller.dart';
import 'model/Info_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PrintController printController = Get.find<PrintController>();
  WebSocketController webSocketController = Get.find<WebSocketController>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<FormState> socketFormKey = GlobalKey<FormState>();
  final ipController = TextEditingController();
  final portController = TextEditingController(text: "9001");
  final printerKeyController = TextEditingController();
  final webSocketUrlController = TextEditingController();
  final timeOutController = TextEditingController(text: "30");

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    printerKeyController.dispose();
    webSocketUrlController.dispose();
    timeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (Platform.isWindows || Platform.isLinux)
                  const WindowsTopActionBar(),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  child: Row(
                    children: [
                      Expanded(
                          child: InfoComponents(
                        data: [
                          InfoModel(
                              title: "Address",
                              value: webSocketController.ipAddress),
                          InfoModel(
                              title: "Port",
                              value: webSocketController.port.toString())
                        ],
                        title: "GENERAL",
                      )),
                      const SizedBox(
                        width: 32,
                      ),
                      Expanded(
                          child: Obx(
                              ()=> InfoComponents(
                        data: [
                            InfoModel(
                                title: "Socket Address",
                                value:
                                    "ws://${webSocketController.ipAddress}:${webSocketController.port} "),
                            InfoModel(
                                title: "Socket Status",
                                widget: webSocketController.isConnected.value ==
                                        true
                                    ? Chip(
                                        label: Text("Running",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.w500)),
                                        backgroundColor:
                                            Colors.green.withOpacity(0.4),
                                      )
                                    : Chip(
                                        label: Text("Disconnected",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w500)),
                                        backgroundColor:
                                            Colors.red.withOpacity(0.4),
                                      )),
                        ],
                        title: "WEB SOCKET",
                      ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomDropButton(
                          onPressed: () {},
                          icon: "assets/icons/plus.svg",
                          title: "Add Printer"),
                      const SizedBox(
                        width: 10,
                      ),
                      CustomButton(
                          onPressed: () {
                            printController
                                .saveSelectedPrinterMapToSharedPreferences(
                                    printController.selectedPrinterMap.value);
                          },
                          icon: "assets/icons/save.svg",
                          isOutlined: true,
                          iconColor: Colors.black,
                          title: "Save List"),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Obx(
                  () => SingleChildScrollView(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                          columnSpacing: Platform.isWindows == true
                              ? 80
                              : MediaQuery.of(context).size.width * 0.2,
                          columns: [
                            DataColumn(
                                label: Text(
                              "PRINTER KEY",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                      color: Colors.black.withOpacity(0.7)),
                            )),
                            DataColumn(
                                label: Text("DEVICE NAME",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.black
                                                .withOpacity(0.7)))),
                            DataColumn(
                                label: Text("STATUS",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.black
                                                .withOpacity(0.7)))),
                            DataColumn(
                                label: Text("ACTION",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.black
                                                .withOpacity(0.7)))),
                          ],
                          rows: printController.selectedPrinterMap.value.isEmpty
                              ? [
                                  // Wrap the single DataRow in a List
                                  const DataRow(cells: [
                                    DataCell(Text("No Device Selected")),
                                    DataCell(Text("No Device Selected")),
                                    DataCell(Text("No Device Selected")),
                                    DataCell(Text("No Device Selected")),
                                  ]),
                                ]
                              : printController.selectedPrinterMap.value
                                  .map((e) => DataRow(cells: [
                                        DataCell(
                                            Text(e.key ?? "No Device Data")),
                                        DataCell(
                                          Text(
                                            e.printer?.deviceName ??
                                                "No Device Data",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        DataCell(
                                          e.status == "Connecting"
                                              ? const SpinKitThreeBounce(
                                                  color: Colors.grey,
                                                  size: 12,
                                                )
                                              : getStatusChip(
                                                  e.status ?? "No Device Data"),
                                        ),
                                        DataCell(SingleChildScrollView(
                                          child: Row(
                                            children: [
                                              Tooltip(
                                                message: "Test Printer",
                                                child: IconButton(
                                                  onPressed: () {
                                                    printController
                                                        .printCommand(
                                                            e, null, true);
                                                  },
                                                  splashRadius: 10,
                                                  icon: SizedBox(
                                                    height: 89,
                                                    width: 89,
                                                    child: Image.asset(
                                                        "assets/icons/printer.png"),
                                                  ),
                                                ),
                                              ),
                                              Tooltip(
                                                message: "Refresh Connection",
                                                child: IconButton(
                                                  onPressed: () {
                                                    printController
                                                        .connectOneDevice(e);
                                                  },
                                                  splashRadius: 10,
                                                  icon: SizedBox(
                                                    height: 89,
                                                    width: 89,
                                                    child: Image.asset(
                                                        "assets/icons/refresh.png"),
                                                  ),
                                                ),
                                              ),
                                              Tooltip(
                                                message: "Delete  Config",
                                                child: IconButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          title: const Text(
                                                              'Confirmation'),
                                                          content: const Text(
                                                              'Are you sure you want to delete this config?'),
                                                          actions: <Widget>[
                                                            TextButton(
                                                              onPressed: () {
                                                                // Perform the action to delete the config
                                                                printController
                                                                    .removeMapPrinter(
                                                                        e);
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close the dialog
                                                              },
                                                              child: const Text(
                                                                  'Yes'),
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop(); // Close the dialog
                                                              },
                                                              child: const Text(
                                                                  'No'),
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                    //
                                                    // printController
                                                    //     .removeMapPrinter(e);
                                                  },
                                                  splashRadius: 10,
                                                  icon: SizedBox(
                                                    height: 89,
                                                    width: 89,
                                                    child: Image.asset(
                                                        "assets/icons/bin.png"),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                      ]))
                                  .toList()),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getStatusChip(String status) {
    switch (status) {
      case "Connected":
        return CustomChip(
          status: status,
          bgColor: Colors.green,
          iconColor: Colors.green,
        );
      case "Connecting":
        return CustomChip(
          status: status,
          bgColor: Colors.orange.withOpacity(0.5),
          iconColor: Colors.orange,
        );
      default:
        return CustomChip(
          status: status,
        );
    }
  }
}
