import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Service for QR code generation and scanning
class QrService {
  /// Generates a QR code widget for the given [data] string.
  Widget generateQrCode(String data, {double size = 200}) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  /// Returns a widget that scans QR codes and calls [onScanned] with the scanned string (chatId).
  Widget buildQrScanner({required void Function(String chatId) onScanned}) {
    return MobileScanner(
      onDetect: (capture) {
        final List<Barcode> barcodes = capture.barcodes;
        for (final barcode in barcodes) {
          final String? code = barcode.rawValue;
          if (code != null && code.isNotEmpty) {
            onScanned(code);
            break;
          }
        }
      },
    );
  }
}
