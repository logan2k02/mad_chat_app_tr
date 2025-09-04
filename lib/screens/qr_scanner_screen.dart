import 'package:flutter/material.dart';

import '../services/qr_service.dart';

/// Screen to scan a QR code and join a chat session
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _scanned = false;
  final QrService _qrService = QrService();

  void _onScanned(String chatId) {
    if (_scanned) return; // Prevent multiple scans
    setState(() {
      _scanned = true;
    });
    if (chatId.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/chat', arguments: chatId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid QR code. Please try again.')),
      );
      setState(() {
        _scanned = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Chat QR')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 300,
              child: _qrService.buildQrScanner(onScanned: _onScanned),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(180, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
