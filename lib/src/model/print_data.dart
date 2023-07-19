import 'package:flutter_pos_printer_platform/esc_pos_utils_platform/src/generator.dart';

class PrintData {
  final Generator generator;
  final List<int> bytes;

  PrintData(this.generator, this.bytes);
}