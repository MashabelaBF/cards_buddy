import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool _scanned = false;

  void _onDetect(BarcodeCapture capture, BuildContext context) {
    if (_scanned) return;
    final code = capture.barcodes.first.rawValue;
    if (code != null && code.isNotEmpty) {
      setState(() {
        _scanned = true;
      });
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Card")),
      body: MobileScanner(
        onDetect: (barcode) => _onDetect(barcode, context),
      ),
    );
  }
}