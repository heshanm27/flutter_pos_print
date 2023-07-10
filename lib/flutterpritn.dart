import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/esc_pos_utils_platform.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
class FlutterPRint extends StatefulWidget {
  const FlutterPRint({Key? key}) : super(key: key);

  @override
  State<FlutterPRint> createState() => _FlutterPRintState();
}

class _FlutterPRintState extends State<FlutterPRint> {
  // Printer Type [bluetooth, usb, network]
  var defaultPrinterType = PrinterType.network;
  var _isBle = false;
  var _reconnect = false;
  var _isConnected = false;
  var printerManager = PrinterManager.instance;
  var devices = <BluetoothPrinter>[];
  StreamSubscription<PrinterDevice>? _subscription;
  StreamSubscription<BTStatus>? _subscriptionBtStatus;
  StreamSubscription<USBStatus>? _subscriptionUsbStatus;

  BTStatus _currentStatus = BTStatus.none;

  // _currentUsbStatus is only supports on Android
  // ignore: unused_field
  USBStatus _currentUsbStatus = USBStatus.none;
  List<int>? pendingTask;
  String _ipAddress = '';
  String _port = '9100';
  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  BluetoothPrinter? selectedPrinter;

  @override
  void initState() {
    if (Platform.isWindows) defaultPrinterType = PrinterType.usb;
    super.initState();
    _portController.text = _port;
    _scan();

    // subscription to listen change status of bluetooth connection
    _subscriptionBtStatus =
        PrinterManager.instance.stateBluetooth.listen((status) {
      log(' ----------------- status bt $status ------------------ ');
      _currentStatus = status;
      if (status == BTStatus.connected) {
        setState(() {
          _isConnected = true;
        });
      }
      if (status == BTStatus.none) {
        setState(() {
          _isConnected = false;
        });
      }
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
    _subscriptionUsbStatus = PrinterManager.instance.stateUSB.listen((status) {
      log(' ----------------- status usb $status ------------------ ');
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
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscriptionBtStatus?.cancel();
    _subscriptionUsbStatus?.cancel();
    _portController.dispose();
    _ipController.dispose();
    super.dispose();
  }

  // method to scan devices according PrinterType
  void _scan() {
    devices.clear();
    _subscription = printerManager
        .discovery(type: defaultPrinterType, isBle: _isBle)
        .listen((device) {
      devices.add(BluetoothPrinter(
        deviceName: device.name,
        address: device.address,
        isBle: _isBle,
        vendorId: device.vendorId,
        productId: device.productId,
        typePrinter: defaultPrinterType,
      ));
      setState(() {});
    });
  }

  void setPort(String value) {
    if (value.isEmpty) value = '9100';
    _port = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void setIpAddress(String value) {
    _ipAddress = value;
    var device = BluetoothPrinter(
      deviceName: value,
      address: _ipAddress,
      port: _port,
      typePrinter: PrinterType.network,
      state: false,
    );
    selectDevice(device);
  }

  void selectDevice(BluetoothPrinter device) async {
    if (selectedPrinter != null) {
      if ((device.address != selectedPrinter!.address) ||
          (device.typePrinter == PrinterType.usb &&
              selectedPrinter!.vendorId != device.vendorId)) {
        await PrinterManager.instance
            .disconnect(type: selectedPrinter!.typePrinter);
      }
    }

    selectedPrinter = device;
    setState(() {});
  }

  Future _printReceiveTest() async {
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
      if (data.lengthInBytes > 0) {
        final Uint8List imageBytes = data.buffer.asUint8List();
        // decode the bytes into an image
        final decodedImage = img.decodeImage(imageBytes)!;
        // Create a black bottom layer
        // Resize the image to a 130x? thumbnail (maintaining the aspect ratio).
        img.Image thumbnail = img.copyResize(decodedImage, height: 130);
        // // creates a copy of the original image with set dimensions
        img.Image originalImg =
        img.copyResize(decodedImage, width: 300, height: 100);
        // // fills the original image with a white background
        // img.fill(originalImg, color: img.ColorRgb8(255, 255, 255));
        // var padding = (originalImg.width - thumbnail.width) / 2;

        // //insert the image inside the frame and center it
        // drawImage(originalImg, thumbnail, dstX: padding.toInt());

        // convert image to grayscale
        var grayscaleImage = img.grayscale(originalImg);

        bytes += generator.feed(1);
         //bytes += generator.imageRaster(img.decodeImage(imageBytes)!, align: PosAlign.center);
        bytes += generator.imageRaster(grayscaleImage, align: PosAlign.center);
        bytes += generator.feed(1);
      }

    bytes += generator.setStyles(const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
        bold: true));
    bytes += generator.text('CineSync',
        styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2));
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
    bytes += generator.textLeftRight("Screen","Room premium");
    bytes += generator.textLeftRight("Show Date","10/07/2023");
    bytes += generator.textLeftRight("Show Time","14:01");
    bytes += generator.textLeftRight("Seat No","D10");
    bytes += generator.textLeftRight("Type ","Students");

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
    bytes +=  generator.qrcode('example.com');
    // const String base64String = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAASIAAAEiAQMAAABncE31AAAABlBMVEX///8AAABVwtN+AAAACXBIWXMAAA7EAAAOxAGVKw4bAAABVklEQVRoge3Yyw3DIAwGYEsZICOxOiMxQCQ3+IEhUnvCufT3IW3I15NrO0CEQPxlnGxR72+6VPgiX72gEpV9cnWgqi5PoZKUJOKxLAm7L1CvqPOyZ3YL9Z7qd6WRVwfUG8rKgQ5WJb+sy1OoFBUTOUrk19yG2qam6Bnyifw9oHYq70L9clPmdrD+aFQHVIbqn6VJcqwcbkVeIo2g8pRT7UI6FXqa6jOPUPuVz+ExjG3329MUGYJKUP28YRTG9I18NkOlqaDSnppMBXJFBJWnJAfyOtpsKyCz2XLVoBLVWI6USK5IX46gEpU/sy4UCWOf0lBZKuK0qWA7MO1WTwS1UcXJA/nRzxjGU3VAZSj7/2t1FJ5LZM0eVILSLlRjDHhngnpLje2uvo7y0pmgUpUeu/lErt6eoDKVhE6FsfHVtfmdCWq/Yovq52y675ISiQxBJSgE4u/iAw0LD+J69uwvAAAAAElFTkSuQmCC";
    // final List<int> qrByte = base64.decode(base64String);
    // bytes += generator.qrcode(base64String,align: PosAlign.center,size: QRSize.Size4);
    bytes += generator.hr(ch: '-', len: 32, linesAfter: 1);
    bytes += generator.text('No refund or exchange',
        styles: const PosStyles(align: PosAlign.center,bold: true));
    bytes += generator.emptyLines(1);
    bytes += generator.text('Technology Partner www.cinesync.io',
        styles: const PosStyles(align: PosAlign.center,bold: true));
    _printEscPos(bytes, generator);
  }

  /// print ticket
  void _printEscPos(List<int> bytes, Generator generator) async {
    var connectedTCP = false;
    if (selectedPrinter == null) return;
    var bluetoothPrinter = selectedPrinter!;

    switch (bluetoothPrinter.typePrinter) {
      case PrinterType.usb:
        bytes += generator.feed(2);
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: UsbPrinterInput(
                name: bluetoothPrinter.deviceName,
                productId: bluetoothPrinter.productId,
                vendorId: bluetoothPrinter.vendorId));
        pendingTask = null;
        break;
      case PrinterType.bluetooth:
        bytes += generator.cut();
        await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
            model: BluetoothPrinterInput(
                name: bluetoothPrinter.deviceName,
                address: bluetoothPrinter.address!,
                isBle: bluetoothPrinter.isBle ?? false,
                autoConnect: _reconnect));
        pendingTask = null;
        if (Platform.isAndroid) pendingTask = bytes;
        break;
      case PrinterType.network:
        bytes += generator.feed(2);
        bytes += generator.cut();
        connectedTCP = await printerManager.connect(
            type: bluetoothPrinter.typePrinter,
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

  // conectar dispositivo
  _connectDevice() async {
    _isConnected = false;
    if (selectedPrinter == null) return;
    switch (selectedPrinter!.typePrinter) {
      case PrinterType.usb:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: UsbPrinterInput(
                name: selectedPrinter!.deviceName,
                productId: selectedPrinter!.productId,
                vendorId: selectedPrinter!.vendorId));
        _isConnected = true;
        break;
      case PrinterType.bluetooth:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: BluetoothPrinterInput(
                name: selectedPrinter!.deviceName,
                address: selectedPrinter!.address!,
                isBle: selectedPrinter!.isBle ?? false,
                autoConnect: _reconnect));
        break;
      case PrinterType.network:
        await printerManager.connect(
            type: selectedPrinter!.typePrinter,
            model: TcpPrinterInput(ipAddress: selectedPrinter!.address!));
        _isConnected = true;
        break;
      default:
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Pos Plugin Platform example app'),
        ),
        body: Center(
          child: Container(
            height: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedPrinter == null || _isConnected
                                ? null
                                : () {
                                    _connectDevice();
                                  },
                            child: const Text("Connect",
                                textAlign: TextAlign.center),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: selectedPrinter == null || !_isConnected
                                ? null
                                : () {
                                    if (selectedPrinter != null)
                                      printerManager.disconnect(
                                          type: selectedPrinter!.typePrinter);
                                    setState(() {
                                      _isConnected = false;
                                    });
                                  },
                            child: const Text("Disconnect",
                                textAlign: TextAlign.center),
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropdownButtonFormField<PrinterType>(
                    value: defaultPrinterType,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.print,
                        size: 24,
                      ),
                      labelText: "Type Printer Device",
                      labelStyle: TextStyle(fontSize: 18.0),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    items: <DropdownMenuItem<PrinterType>>[
                      if (Platform.isAndroid || Platform.isIOS)
                        const DropdownMenuItem(
                          value: PrinterType.bluetooth,
                          child: Text("bluetooth"),
                        ),
                      if (Platform.isAndroid || Platform.isWindows)
                        const DropdownMenuItem(
                          value: PrinterType.usb,
                          child: Text("usb"),
                        ),
                      const DropdownMenuItem(
                        value: PrinterType.network,
                        child: Text("Wifi"),
                      ),
                    ],
                    onChanged: (PrinterType? value) {
                      setState(() {
                        if (value != null) {
                          setState(() {
                            defaultPrinterType = value;
                            selectedPrinter = null;
                            _isBle = false;
                            _isConnected = false;
                            _scan();
                          });
                        }
                      });
                    },
                  ),
                  Visibility(
                    visible: defaultPrinterType == PrinterType.bluetooth &&
                        Platform.isAndroid,
                    child: SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.only(bottom: 20.0, left: 20),
                      title: const Text(
                        "This device supports ble (low energy)",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 19.0),
                      ),
                      value: _isBle,
                      onChanged: (bool? value) {
                        setState(() {
                          _isBle = value ?? false;
                          _isConnected = false;
                          selectedPrinter = null;
                          _scan();
                        });
                      },
                    ),
                  ),
                  Visibility(
                    visible: defaultPrinterType == PrinterType.bluetooth &&
                        Platform.isAndroid,
                    child: SwitchListTile.adaptive(
                      contentPadding:
                          const EdgeInsets.only(bottom: 20.0, left: 20),
                      title: const Text(
                        "reconnect",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 19.0),
                      ),
                      value: _reconnect,
                      onChanged: (bool? value) {
                        setState(() {
                          _reconnect = value ?? false;
                        });
                      },
                    ),
                  ),
                  Column(
                      children: devices
                          .map(
                            (device) => ListTile(
                              title: Text('${device.deviceName}'),
                              subtitle: Platform.isAndroid &&
                                      defaultPrinterType == PrinterType.usb
                                  ? null
                                  : Visibility(
                                      visible: !Platform.isWindows,
                                      child: Text("${device.address}")),
                              onTap: () {
                                // do something
                                selectDevice(device);
                              },
                              leading: selectedPrinter != null &&
                                      ((device.typePrinter == PrinterType.usb &&
                                                  Platform.isWindows
                                              ? device.deviceName ==
                                                  selectedPrinter!.deviceName
                                              : device.vendorId != null &&
                                                  selectedPrinter!.vendorId ==
                                                      device.vendorId) ||
                                          (device.address != null &&
                                              selectedPrinter!.address ==
                                                  device.address))
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : null,
                              trailing: OutlinedButton(
                                onPressed: selectedPrinter == null ||
                                        device.deviceName !=
                                            selectedPrinter?.deviceName
                                    ? null
                                    : () async {
                                        _printReceiveTest();
                                      },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 20),
                                  child: Text("Print test ticket",
                                      textAlign: TextAlign.center),
                                ),
                              ),
                            ),
                          )
                          .toList()),
                  Visibility(
                    visible: defaultPrinterType == PrinterType.network &&
                        Platform.isWindows,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: _ipController,
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: true),
                        decoration: const InputDecoration(
                          label: Text("Ip Address"),
                          prefixIcon: Icon(Icons.wifi, size: 24),
                        ),
                        onChanged: setIpAddress,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: defaultPrinterType == PrinterType.network &&
                        Platform.isWindows,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: TextFormField(
                        controller: _portController,
                        keyboardType:
                            const TextInputType.numberWithOptions(signed: true),
                        decoration: const InputDecoration(
                          label: Text("Port"),
                          prefixIcon: Icon(Icons.numbers_outlined, size: 24),
                        ),
                        onChanged: setPort,
                      ),
                    ),
                  ),
                  Visibility(
                    visible: defaultPrinterType == PrinterType.network &&
                        Platform.isWindows,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: OutlinedButton(
                        onPressed: () async {
                          if (_ipController.text.isNotEmpty)
                            setIpAddress(_ipController.text);
                          _printReceiveTest();
                        },
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 50),
                          child: Text("Print test ticket",
                              textAlign: TextAlign.center),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BluetoothPrinter {
  int? id;
  String? deviceName;
  String? address;
  String? port;
  String? vendorId;
  String? productId;
  bool? isBle;

  PrinterType typePrinter;
  bool? state;

  BluetoothPrinter(
      {this.deviceName,
      this.address,
      this.port,
      this.state,
      this.vendorId,
      this.productId,
      this.typePrinter = PrinterType.bluetooth,
      this.isBle = false});
}
