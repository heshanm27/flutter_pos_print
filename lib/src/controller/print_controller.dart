import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/enums.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/generator.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:flutter_print/src/model/printer_model.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/print_data.dart';
import '../model/printer_map_model.dart';
import '../model/websocket_model.dart';
import '../model/websocket_response_model.dart';
import 'image_controller.dart';
import 'package:image/image.dart' as img;

class PrintController extends GetxController {
  var defaultPrinterType = PrinterType.usb;
  RxBool isBle = false.obs;
  RxBool reconnect = false.obs;
  var printerManager = PrinterManager.instance;
  RxList<PrinterModel> devices = <PrinterModel>[].obs;
  RxList<PrintMapModel> selectedPrinterMap = <PrintMapModel>[].obs;
  StreamSubscription<PrinterDevice>? subscription;
  StreamSubscription<BTStatus>? subscriptionBtStatus;
  StreamSubscription<USBStatus>? subscriptionUsbStatus;

  BTStatus _currentStatus = BTStatus.none;
  USBStatus _currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;
  Rx<PrinterModel?> selectedPrinter = PrinterModel().obs;

  @override
  void onInit() {
    if (Platform.isWindows) defaultPrinterType = PrinterType.usb;
    if (Platform.isAndroid) defaultPrinterType = PrinterType.bluetooth;
    if (Platform.isAndroid) isBle.value = true;
    super.onInit();
    scan();

    // subscription to listen change status of bluetooth connection
    subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      _currentStatus = status;

      if (status == BTStatus.connected && pendingTask != null) {
        if (Platform.isAndroid) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.bluetooth, bytes: pendingTask!);
            pendingTask = null;
          });
        } else if (Platform.isIOS) {
          PrinterManager.instance
              .send(type: PrinterType.bluetooth, bytes: pendingTask!);
          pendingTask = null;
        }
      }
    });

    //  PrinterManager.instance.stateUSB is only supports on Android
    subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      _currentUsbStatus = status;
      if (Platform.isAndroid) {
        if (status == USBStatus.connected && pendingTask != null) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            PrinterManager.instance
                .send(type: PrinterType.usb, bytes: pendingTask!);
            pendingTask = null;
          });
        }
      }
    });
    loadCacheFromStorage();
  }

  @override
  void onReady() {
    super.onReady();
    everAll([reconnect, isBle], (callback) {
      debugPrint('reconnect: $reconnect');
      debugPrint('isBle: $isBle');
      scan();
    });
  }

  @override
  void onClose() {
    // Cancel the subscriptions to avoid memory leaks
    subscription?.cancel();
    subscriptionBtStatus?.cancel();
    subscriptionUsbStatus?.cancel();
    super.onClose();
  }

  //Scan devices according to the default printer type
  void scan() {
    devices.clear();
    subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: isBle.value)
        .listen((device) {
      devices.add(PrinterModel(
        deviceName: device.name,
        address: device.address,
        isBle: isBle.value,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
    });
  }

  //refresh scan
  void refreshScan(PrinterType type) {
    defaultPrinterType = type;
    scan();
  }

  //Select device
  void selectDevice(PrinterModel device) async {
    if (selectedPrinter != null) {
      if ((device.address != selectedPrinter.value!.address) ||
          (device.typePrinter == PrinterType.usb &&
              selectedPrinter.value!.vendorId != device.vendorId)) {
        await PrinterManager.instance
            .disconnect(type: selectedPrinter.value!.typePrinter);
      }
    }

    selectedPrinter.value = device;
  }

  //map printer to key
  void mapPrinterToKey(String key, PrinterModel printer) {
    selectedPrinterMap.add(PrintMapModel(
        mapId: selectedPrinterMap.length,
        key: key,
        printer: printer,
        deviceName: printer.deviceName,
        isConnected: true,
        status: 'Connected'));
    refresh();
    update();
    // connectMapDeviceTo();
  }

  //connect printers
  void connectMapDeviceTo() {
    for (var element in selectedPrinterMap) {
      if (element.printer == null) continue;
      connectDevice(element.printer!).then((value) {
        if (value == true) {
          element.isConnected = true;
          element.status = 'Connected';
        } else {
          element.isConnected = false;
        }
      });
    }
  }

  //connect one printer
  void connectOneDevice(PrintMapModel element) {
    changePrinterStatus(element, 'Connecting');
    connectDevice(element.printer!).then((value) {
      if (value == true) {
        element.isConnected = true;
        element.status = 'Connected';
        debugPrint("${element.deviceName} device connected");
        selectedPrinterMap.refresh();
      } else {
        changePrinterStatus(element, 'Disconnected');
        element.isConnected = false;
      }
    });
  }

  //change status of printer
  void changePrinterStatus(PrintMapModel device, String status) {
    if (device.printer == null) return;
    for (var element in selectedPrinterMap) {
      if (element.mapId == device.mapId) {
        element.status = status;
      }
    }
    update();
  }

  //add TcpIp printer
  void addTcpIpPrinter(String key, String address, String port) {
    PrinterModel printer = PrinterModel(
      deviceName: address,
      address: address,
      port: port,
      typePrinter: PrinterType.network,
      state: false,
    );
    mapPrinterToKey(key, printer);
  }

  //remove printer from map
  void removeMapPrinter(PrintMapModel mapModel) {
    selectedPrinterMap.remove(mapModel);
    refresh();
    update();
  }

  //test Print
  Future<PrintData> printReceiveTest() async {
    List<int> bytes = [];

    // default profile
    final profile = await CapabilityProfile.load();
    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(PaperSize.mm80, profile);
    bytes += generator.setStyles(const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        bold: true));
    bytes += generator.text('CineSync',
        styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.text('456 Oak Avenue Somewhereville,Canada.',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Hotline :',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('info@cinecinema.com',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('https://cinesync-v2-stg.layoutindex.dev',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr(ch: '-', len: 48);
    bytes += generator.text('Transaction #:2307-1033-5930-5392',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr(ch: '-', len: 48);
    bytes += generator.text('Elemental',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.emptyLines(1);
    bytes += generator.textLeftRight("Screen", "Room premium");
    bytes += generator.textLeftRight("Show Date", "10/07/2023");
    bytes += generator.textLeftRight("Show Time", "14:01");
    bytes += generator.textLeftRight("Seat No", "D10");
    bytes += generator.textLeftRight("Type ", "Students");


    bytes += generator.emptyLines(1);
    bytes += generator.qrcode('example.com');
    bytes += generator.hr(ch: '-', len: 32, linesAfter: 1);
    bytes += generator.text('No refund or exchange',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.emptyLines(1);
    bytes += generator.text('Technology Partner www.cinesync.io',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    return PrintData(generator, bytes);
  }

  //print file from template
  Future<PrintData> printFileFromTemplate(WebSocketModel? webData) async {
    List<int> bytes = [];
    // default profile
    final profile = await CapabilityProfile.load();
    // PaperSize.mm80 or PaperSize.mm58

    PaperSize paperSize;

    if (webData?.paperSize == 'mm58') {
      paperSize = PaperSize.mm58;
    } else {
      paperSize = PaperSize.mm80;
    }

    final generator = Generator(
        webData?.paperSize != null ? paperSize : PaperSize.mm80, profile);

    if (webData?.logo != null) {
      if (webData?.logo?.isNotEmpty == true) {
        final File? imageFile =
            await ImageController.downloadImageAndDisplay(webData!.logo!);
        debugPrint('imageFile: $imageFile');
        if (imageFile != null) {
          // Image downloaded successfully, continue with processing
          final Uint8List imageBytes = await imageFile.readAsBytes();
          // decode the bytes into an image
          final decodedImage = img.decodeImage(imageBytes)!;
          // Resize the image to a 130x? thumbnail (maintaining the aspect ratio).
          img.Image thumbnail = img.copyResize(decodedImage, height: 130);
          //  creates a copy of the original image with set dimensions
          img.Image originalImg =
              img.copyResize(decodedImage, width: 300, height: 100);

          img.fill(originalImg, color: img.ColorRgb8(255, 255, 255));

          // convert image to grayscale
          var grayscaleImage = img.grayscale(originalImg);
          debugPrint('grayscaleImage: $grayscaleImage');
          bytes += generator.feed(1);
          bytes += generator.image(grayscaleImage, align: PosAlign.center);
          bytes += generator.feed(1);
        }
      }
    }

    bytes += generator.setStyles(const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        bold: true));
    bytes += generator.text('CineSync',
        styles: const PosStyles(
            align: PosAlign.center,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size2));
    bytes += generator.text('456 Oak Avenue Somewhereville,Canada.',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Hotline :',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('info@cinecinema.com',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('https://cinesync-v2-stg.layoutindex.dev',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr(ch: '-', len: 48);
    bytes += generator.text('Transaction #:2307-1033-5930-5392',
        styles: const PosStyles(align: PosAlign.center));
    bytes += generator.hr(ch: '-', len: 48);
    bytes += generator.text('Elemental',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.emptyLines(1);
    bytes += generator.textLeftRight("Screen", "Room premium");
    bytes += generator.textLeftRight("Show Date", "10/07/2023");
    bytes += generator.textLeftRight("Show Time", "14:01");
    bytes += generator.textLeftRight("Seat No", "D10");
    bytes += generator.textLeftRight("Type ", "Students");
    bytes += generator.emptyLines(1);

    //handle qr code
    if (webData?.qrUrl != null) {
      if (webData?.qrUrl?.isNotEmpty == true) {
        bytes += generator.qrcode(webData!.qrUrl!);
      }
    }
    // bytes += generator.qrcode(base64String,align: PosAlign.center,size: QRSize.Size4);
    bytes += generator.hr(ch: '-', len: 32, linesAfter: 1);
    bytes += generator.text('No refund or exchange',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.emptyLines(1);
    bytes += generator.text('Technology Partner www.cinesync.io',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    return PrintData(generator, bytes);
  }

  //execute print command
  Future<WebSocketResponseModel> printCommand(
      PrintMapModel model, WebSocketModel? data, bool isTest) async {
    PrintData printingData;
    changePrinterStatus(model, 'Printing');
    if (model.isConnected == false) {
      Get.snackbar('Error', 'Printer is not connected');
      return WebSocketResponseModel(
          status: false, message: 'Printer is not connected');
    }
    if (isTest == true) {
      printingData = await printReceiveTest();
    } else {
      if (data!.data!.isEmpty) {
        return WebSocketResponseModel(
            status: false, message: 'Print data is empty');
      }
      printingData = await printFileFromTemplate(data);
    }
    if (printingData == null) {
      Get.snackbar('Error', 'Print data is null');
      return WebSocketResponseModel(
          status: false, message: 'Print data is null');
    }
    await printEscPos(printingData, model.printer!);
    changePrinterStatus(model, 'Connected');
    return WebSocketResponseModel(status: true, message: 'Print success');
  }

  //connect device
  Future<bool> connectDevice(PrinterModel device) async {
    switch (device.typePrinter) {
      case PrinterType.usb:
        return await printerManager.connect(
            type: device.typePrinter,
            model: UsbPrinterInput(
                name: device.deviceName,
                productId: device.productId,
                vendorId: device.vendorId));
      case PrinterType.bluetooth:
        return await printerManager.connect(
            type: device.typePrinter,
            model: BluetoothPrinterInput(
                name: device.deviceName,
                address: device.address!,
                isBle: device.isBle ?? false,
                autoConnect: reconnect.value));

      case PrinterType.network:
        return await printerManager.connect(
            type: device.typePrinter,
            model: TcpPrinterInput(ipAddress: device.address!));
      default:
        return false;
    }
  }

  //get printer by key
  PrintMapModel? getPrinterByKey(String key) {
    for (var element in selectedPrinterMap) {
      if (element.key == key) {
        return element;
      }
    }
    return null;
  }

  //print command from websocket
  Future<WebSocketResponseModel> webSocketPrintCommand(
      WebSocketModel model) async {
    debugPrint('model.printKey: ${model.printerKey}');
    if (model.printerKey != null) {

      PrintMapModel? printMapModel = getPrinterByKey(model.printerKey!);
      if (printMapModel != null) {
        return await printCommand(printMapModel, model, false);
      }
    }
    return WebSocketResponseModel(
        status: false,
        message: 'Printer with the provided key does not exist.');
  }

  // print ticket on selected printer
  printEscPos(PrintData data, PrinterModel device) async {
    var generator = data.generator;
    var bytes = data.bytes;
    var connectedTCP = false;
    if (selectedPrinter == null) return;
    var bluetoothPrinter = device;
    switch (bluetoothPrinter?.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter!.typePrinter,
            model: UsbPrinterInput(
                name: bluetoothPrinter?.deviceName,
                productId: bluetoothPrinter?.productId,
                vendorId: bluetoothPrinter?.vendorId));
        pendingTask = null;
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter!.typePrinter,
            model: BluetoothPrinterInput(
                name: bluetoothPrinter.deviceName,
                address: bluetoothPrinter.address!,
                isBle: bluetoothPrinter.isBle ?? false,
                autoConnect: reconnect.value));
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        connectedTCP = await printerManager.connect(
            type: bluetoothPrinter!.typePrinter,
            model: TcpPrinterInput(ipAddress: bluetoothPrinter.address!));
        if (!connectedTCP) debugPrint(' --- please review your connection ---');
        break;
      default:
    }
    if (bluetoothPrinter.typePrinter == PrinterType.bluetooth &&
        Platform.isAndroid) {
      if (_currentStatus == BTStatus.connected) {
        printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
        pendingTask = null;
      }
    } else {
      printerManager.send(type: bluetoothPrinter.typePrinter, bytes: bytes);
      if (bluetoothPrinter.typePrinter == PrinterType.network) {
        printerManager.disconnect(type: bluetoothPrinter.typePrinter);
      }
    }
  }

  //print ticket on multi device
  printTicketOnMultiDevice(String key) async {
    for (var value in selectedPrinterMap) {
      if (value.key == key) {
        debugPrint('value.key ${value.key}');
        PrintData printData = await printReceiveTest();
        if (value.printer == null) continue;
        printEscPos(printData, value.printer!);
      }
    }
  }

  //save selected printer map to shared preferences
  Future<void> saveSelectedPrinterMapToSharedPreferences(
      List<PrintMapModel> data) async {
    final prefs = await SharedPreferences.getInstance();

    List<Map<String, dynamic>> list = [];

    for (var value in data) {
      list.add(value.toJson());
    }

    final jsonData = json.encode(list);
    debugPrint('jsonData: $jsonData');
    await prefs.setString('selected_printer_map_data', jsonData);
  }

  //get selected printer map from shared preferences
  Future<List<PrintMapModel>>
      getSelectedPrinterMapFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    //get data from shared preferences
    final jsonData = prefs.getString('selected_printer_map_data');
    // debugPrint('jsonData: $jsonData');

    if (jsonData != null) {
      List<dynamic> data = json.decode(jsonData);
      debugPrint('data: $data');
      List<PrintMapModel> testMap = [];
      for (var element in data) {
        testMap.add(PrintMapModel.fromJson(element));
      }
      return testMap;
    }
    return [];
  }

  //load cache from storage
  Future<void> loadCacheFromStorage() async {
    List<PrintMapModel> cacheList =
        await getSelectedPrinterMapFromSharedPreferences();
    if (cacheList.isNotEmpty) {
      selectedPrinterMap.value = cacheList;
      selectedPrinterMap.refresh();
      update();
    }
    //pre connect printer
    connectMapDeviceTo();
  }
}
