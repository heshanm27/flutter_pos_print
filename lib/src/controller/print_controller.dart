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
import 'package:web_socket_channel/io.dart';
import '../model/print_data.dart';
import '../model/printer_map_model.dart';

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
    // TODO: implement onReady
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

  // void setPort(String value) {
  //   if (value.isEmpty) value = '9100';
  //   _port = value;
  //   var device = PrinterModel(
  //     deviceName: value,
  //     address: _ipAddress,
  //     port: _port,
  //     typePrinter: PrinterType.network,
  //     state: false,
  //   );
  //   selectDevice(device);
  // }
  // void setIpAddress(String value) {
  //   _ipAddress = value;
  //   var device = PrinterModel(
  //     deviceName: value,
  //     address: _ipAddress,
  //     port: _port,
  //     typePrinter: PrinterType.network,
  //     state: false,
  //   );
  //   selectDevice(device);
  // }
  void setNetWorkPrinter(String port, String address) {}

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
  }

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

  //execute print command
  void printCommand(PrintMapModel model) async {
    changePrinterStatus(model, 'Printing');
    if (model.isConnected == false) {
      Get.snackbar('Error', 'Printer is not connected');
      return;
    }
    PrintData printData = await printReceiveTest();
    if (printData == null) {
      Get.snackbar('Error', 'Print data is null');
      return;
    }
    await printEscPos(printData, model.printer!);
    changePrinterStatus(model, 'Connected');
  }

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

  Future<PrintData> printReceiveTest() async {
    List<int> bytes = [];

    // // Xprinter XP-N160I
    // final profile = await CapabilityProfile.load(name: 'XP-N160I');
    // default profile
    final profile = await CapabilityProfile.load();
    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(PaperSize.mm80, profile);
    // bytes += generator.setGlobalCodeTable('CP1250');
    // final String imageUrl = 'https://cinesync-dev.s3.amazonaws.com/report/images/theater/cinema/cinesync_logo-200h.png';
    //
    // final response = await http.get(Uri.parse("imageUrl"));
    // if (response.statusCode == 200) {
    //   final Uint8List imageBytes = response.bodyBytes;
    //   final decodedImage = img.decodeImage(imageBytes)!;
    //
    //   final tempDir = await getTemporaryDirectory();
    //   final tempPath = "${tempDir.path}/temp_image.jpg";
    //   File(tempPath).writeAsBytesSync(img.encodeJpg(decodedImage));

    final ByteData data = await rootBundle.load("assets/Picture1.png");
    // if (data.lengthInBytes > 0) {
    //   final Uint8List imageBytes = data.buffer.asUint8List();
    //   // decode the bytes into an image
    //   final decodedImage = img.decodeImage(imageBytes)!;
    //   // Create a black bottom layer
    //   // Resize the image to a 130x? thumbnail (maintaining the aspect ratio).
    //   img.Image thumbnail = img.copyResize(decodedImage, height: 130);
    //   // // creates a copy of the original image with set dimensions
    //   img.Image originalImg =
    //   img.copyResize(decodedImage, width: 300, height: 100);
    //   // // fills the original image with a white background
    //   // img.fill(originalImg, color: img.ColorRgb8(255, 255, 255));
    //   // var padding = (originalImg.width - thumbnail.width) / 2;
    //
    //   // //insert the image inside the frame and center it
    //   // drawImage(originalImg, thumbnail, dstX: padding.toInt());
    //
    //   // convert image to grayscale
    //   var grayscaleImage = img.grayscale(originalImg);
    //
    //   bytes += generator.feed(1);
    //   //bytes += generator.imageRaster(img.decodeImage(imageBytes)!, align: PosAlign.center);
    //   bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
    //   bytes += generator.feed(1);
    // }

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

    // bytes += generator.emptyLines(1);
    // bytes += generator.row([
    //   PosColumn(
    //       width: 8,
    //       text: 'Screen',
    //       styles: const PosStyles(align: PosAlign.center, bold: true),
    //       ),
    //   PosColumn(
    //       width: 4,
    //       text: ': Room premium',
    //       styles: const PosStyles(align: PosAlign.left, bold: true),
    //      ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //       width: 6,
    //       text: 'Show Date',
    //       styles: const PosStyles(align: PosAlign.right, bold: true),
    //      ),
    //   PosColumn(
    //       width: 6,
    //       text: ' : 10/07/2023',
    //       styles: const PosStyles(align: PosAlign.left, bold: true),
    //       ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //       width: 6,
    //       text: 'Show Time',
    //     styles: const PosStyles(align: PosAlign.right, bold: true),
    //       ),
    //   PosColumn(
    //       width: 6,
    //       text: ': 14:01 ',
    //     styles: const PosStyles(align: PosAlign.left, bold: true),
    //      ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //       width: 6,
    //       text: 'Seat No',
    //     styles: const PosStyles(align: PosAlign.right, bold: true),
    //      ),
    //   PosColumn(
    //       width: 6,
    //       text: ': C17',
    //     styles: const PosStyles(align: PosAlign.left, bold: true),
    //       ),
    // ]);
    // bytes += generator.row([
    //   PosColumn(
    //       width: 8,
    //       text: 'Type',
    //     styles: const PosStyles(align: PosAlign.right, bold: true),
    //      ),
    //   PosColumn(
    //       width: 4,
    //       text: ': Adult',
    //     styles: const PosStyles(align: PosAlign.left, bold: true),
    //      ),
    // ]);

    bytes += generator.emptyLines(1);
    bytes += generator.qrcode('example.com');
    // const String base64String = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASIAAAEiAQMAAABncE31AAAABlBMVEX///8AAABVwtN+AAAACXBIWXMAAA7EAAAOxAGVKw4bAAABVklEQVRoge3Yyw3DIAwGYEsZICOxOiMxQCQ3+IEhUnvCufT3IW3I15NrO0CEQPxlnGxR72+6VPgiX72gEpV9cnWgqi5PoZKUJOKxLAm7L1CvqPOyZ3YL9Z7qd6WRVwfUG8rKgQ5WJb+sy1OoFBUTOUrk19yG2qam6Bnyifw9oHYq70L9clPmdrD+aFQHVIbqn6VJcqwcbkVeIo2g8pRT7UI6FXqa6jOPUPuVz+ExjG3329MUGYJKUP28YRTG9I18NkOlqaDSnppMBXJFBJWnJAfyOtpsKyCz2XLVoBLVWI6USK5IX46gEpU/sy4UCWOf0lBZKuK0qWA7MO1WTwS1UcXJA/nRzxjGU3VAZSj7/2t1FJ5LZM0eVILSLlRjDHhngnpLje2uvo7y0pmgUpUeu/lErt6eoDKVhE6FsfHVtfmdCWq/Yovq52y675ISiQxBJSgE4u/iAw0LD+J69uwvAAAAAElFTkSuQmCC";
    // final List<int> qrByte = base64.decode(base64String);
    // bytes += generator.qrcode(base64String,align: PosAlign.center,size: QRSize.Size4);
    bytes += generator.hr(ch: '-', len: 32, linesAfter: 1);
    bytes += generator.text('No refund or exchange',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.emptyLines(1);
    bytes += generator.text('Technology Partner www.cinesync.io',
        styles: const PosStyles(align: PosAlign.center, bold: true));
    return PrintData(generator, bytes);
  }

  /// print ticket
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
