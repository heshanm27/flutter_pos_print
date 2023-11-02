import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_print/src/components/custom_button.dart';
import 'package:flutter_print/src/components/custom_chip.dart';
import 'package:flutter_print/src/components/drop_down_btn.dart';
import 'package:flutter_print/src/components/info_components.dart';
import 'package:flutter_print/src/components/widget/printing_converted.dart';
import 'package:flutter_print/src/components/window_top_action_bar.dart';
import 'package:flutter_print/src/controller/print_controller.dart';
import 'package:flutter_print/src/controller/websocket_controller.dart';
import 'package:flutter_print/src/model/Info_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:simple_html_css/simple_html_css.dart';
import 'package:html/parser.dart' as htmlparser;
import 'package:html/dom.dart' as dom;
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class FlutterPRint extends StatefulWidget {
  const FlutterPRint({super.key});

  @override
  State<FlutterPRint> createState() => _FlutterPRintState();
}

class _FlutterPRintState extends State<FlutterPRint> {
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
    var parsedData = printController.parsedData;
    print("print controller ${printController.parsedData}");
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
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // PrintingConverter(
                      //   convertedStoreData: printController.parsedData,
                      // ),
                      CustomDropButton(
                          onPressed: () {},
                          icon: "assets/icons/plus.svg",
                          title: "Add Printersad"),
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
                Container(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                          "Data passed: $parsedData"),

                      // HtmlWidget to render the HTML content
                      HtmlWidget(
                        parsedData, // Assuming parsedData contains HTML string
                      ),
                    ],
                  ),
                ),
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
