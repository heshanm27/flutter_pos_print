import 'package:flutter/material.dart';

class PrinterDialog extends StatelessWidget {
  const PrinterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              Text("Printer Key")
            ],
          )
        ],
      ),
    );
  }
}
