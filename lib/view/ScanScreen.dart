import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class ScanScreen extends StatelessWidget {
  final box = Hive.box('cards');

  void _onDetect(BarcodeCapture capture, BuildContext context) {
    final code = capture.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      box.add({
        'code': code,
        'date': DateTime.now().toString(),
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Scan Card")),
      body: MobileScanner(
        onDetect: (barcode) => _onDetect(barcode, context),
      ),
    );
  }
}