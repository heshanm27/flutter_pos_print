import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:flutter_print/src/controller/print_controller.dart';
import 'package:get/get.dart';

import 'model/printer_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    PrintController printController = Get.find<PrintController>();
    final ipController = TextEditingController();
    final portController = TextEditingController();
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
           height: double.infinity,
          padding: const EdgeInsets.all(12),
          child:Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                children: [
                Expanded(
                  child: Container(

                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Text("TCP/IP Printer"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("IP Address: "),
                          Flexible(
                            child: TextFormField(
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
                        children: [
                          const Text("PORT: "),
                          Flexible(
                            child: TextFormField(
                              controller: portController,
                              decoration: const InputDecoration(
                                hintText: 'Enter PORT',
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30,),
                      ElevatedButton(onPressed: (){}, child: const Text("Connect"))
                    ],
                  ),
                    ),
                ),
                  SizedBox(width: 50,),
                  Expanded(
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
                                    decoration: InputDecoration(
                                      hintText: 'Enter Web Socket Url',
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30,),
                            ElevatedButton(onPressed: (){}, child: const Text("Connect"))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(onPressed: (){
                    // showDialog(context: context, builder: (BuildContext context){
                    //   return Column()
                    // });
                  }, child: const Text("Add Printer")),
                ],
              ),
              SizedBox(height: 30,),
              Container(
                  width: 800,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black12,
                      width: 2,
                    ),
                  ),
                  child:Obx(
                    ()=> Table(
                      defaultColumnWidth: const FixedColumnWidth(100),
                      border: TableBorder.all(color: Colors.white10),
                      children:  [
                         const TableRow(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                            ),
                            children: [
                              TableCell(

                                  child: Text("Printer Key",textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white,
                              ),)),
                              TableCell( child: Text("Printer",textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white,
                              ))),
                              TableCell(child: Text("Action",textAlign: TextAlign.center,style: TextStyle(
                                color: Colors.white,
                              ))),
                            ]
                        ),
                        if(printController.selectedPrinterMap.value.isEmpty)
                          const TableRow(
                            children: [
                              TableCell(child: Text("No Printer Selected",textAlign: TextAlign.center)),
                              TableCell(child: Text("No Printer Selected",textAlign: TextAlign.center)),
                              TableCell(child: Text("No Printer Selected",textAlign: TextAlign.center)),
                            ],
                          )
              ,
                        if(printController.selectedPrinterMap.value.isNotEmpty)
                        ...printController.selectedPrinterMap.value.map((element) => TableRow(
                          children: [
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(element.key ?? "",textAlign: TextAlign.center,),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(element.deviceName ?? "",textAlign: TextAlign.center,),
                            )),
                            TableCell(child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(onPressed: (){}, child: const Text("Connect")),
                            ))
                          ],
                        )).toList(),
                      ],
                    ),
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }


  //   Iterable<TableRow> mapDevices(List<PrinterModel> devices)  {
  //       return devices.map((e) =>TableRow(
  //         children: [
  //           TableCell(child: Text(e.deviceName ?? "")),
  //           TableCell(child: Text(e.)),
  //           TableCell(child: ElevatedButton(onPressed: (){}, child: const Text("Connect")))
  //         ],
  //       ));
  //
  //
  // }

}



