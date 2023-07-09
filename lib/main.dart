import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/barcode.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/capability_profile.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/enums.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/generator.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_column.dart';
import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/pos_styles.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'flutterpritn.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),


    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
 late Printer _defaultPrinter;
  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {


    Future<Uint8List> generatePdf() async {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.nunitoExtraLight();

      // // Load the font file
      // final fontData = await rootBundle.load('assets/fonts/YourFontFile.ttf');
      // final ttfFont = pw.Font.ttf(fontData);

      // Add your receipt content using the `pdf` package APIs
      pdf.addPage(
        pw.Page(
          orientation: pw.PageOrientation.portrait,
          pageFormat: PdfPageFormat.roll80,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Text(
                'Your receipt content goes here',
                style: pw.TextStyle(font: font, fontSize: 12),
              ),
            );
          },
        ),
      );
      // Save the PDF as Uint8List
      final Uint8List pdfBytes = await pdf.save();

      return pdfBytes;
    }



    Future<void> checkLocalPrinters() async {
      final printers = await Printing.listPrinters();

      // Display information about each printer
      for (final printer in printers) {
        if(printer.isDefault && printer.isAvailable){
          print('Printer Name -------------default: ${printer.name}');
          _defaultPrinter = printer;
        }
        print('Printer Name: ${printer.name}');
        print('Is Default Printer: ${printer.isDefault}');
        print('Supported Capabilities: ${printer.model}');

        print('---');
      }
    }
    Future<List<int>> espos() async {
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];

      bytes += generator.text(
          'Regular: aA bB cC dD eE fF gG hH iI jJ kK lL mM nN oO pP qQ rR sS tT uU vV wW xX yY zZ');
      bytes += generator.text('Special 1: àÀ èÈ éÉ ûÛ üÜ çÇ ôÔ',
          styles: const PosStyles(codeTable: 'CP1252'));
      bytes += generator.text('Special 2: blåbærgrød',
          styles: const PosStyles(codeTable: 'CP1252'));

      bytes += generator.text('Bold text', styles: const PosStyles(bold: true));
      bytes +=
          generator.text('Reverse text', styles: const PosStyles(reverse: true));
      bytes += generator.text('Underlined text',
          styles: const PosStyles(underline: true), linesAfter: 1);
      bytes += generator.text('Align left',
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text('Align center',
          styles: const PosStyles(align: PosAlign.center));
      bytes += generator.text('Align right',
          styles: const PosStyles(align: PosAlign.right), linesAfter: 1);

      bytes += generator.row([
        PosColumn(
          text: 'col3',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, underline: true),
        ),
        PosColumn(
          text: 'col6',
          width: 6,
          styles: const PosStyles(align: PosAlign.center, underline: true),
        ),
        PosColumn(
          text: 'col3',
          width: 3,
          styles: const PosStyles(align: PosAlign.center, underline: true),
        ),
      ]);

      bytes += generator.text('Text size 200%',
          styles: const PosStyles(
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ));

      // Print barcode
      final List<int> barData = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 4];
      bytes += generator.barcode(Barcode.upcA(barData));

      bytes += generator.feed(2);
      bytes += generator.cut();
      return bytes;
    }
    Future<void> printPdf() async {
      await checkLocalPrinters();
      final pdfBytes = await generatePdf();

      // final selectedPrinter = await Printing.pickPrinter(context: context);

      // Check if a printer was selected
      if (_defaultPrinter != null) {
        // Print the PDF to the selected printer
        await Printing.directPrintPdf(
         dynamicLayout: true,
          onLayout: (PdfPageFormat format) => pdfBytes,
          printer: _defaultPrinter,
          
          format: PdfPageFormat.roll80,
          name: 'My Document',
        );
      } else {
        // User canceled printer selection
        // Handle this case accordingly
      }
      // await Printing.directPrintPdf(
      //   onLayout: (PdfPageFormat format) => pdfBytes,
      //   name: 'My Document',
      //   printer: _defaultPrinter,
      //
      // );
    }
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) {
                  return FlutterPRint();
                }),
              );
            }, child: Text('Detail Screen'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: printPdf,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
