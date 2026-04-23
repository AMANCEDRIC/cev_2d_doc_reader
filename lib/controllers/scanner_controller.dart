import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/doc2d_model.dart';
import '../services/parser_service.dart';
import '../services/crypto_service.dart';

class ScannerController extends ChangeNotifier {
  final ParserService _parser = ParserService();
  final CryptoService _crypto = CryptoService();
  
  late final MobileScannerController cameraController;
  
  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;
  
  bool _isCameraActive = false;
  bool get isCameraActive => _isCameraActive;
  
  bool _showManual = false;
  bool get showManual => _showManual;

  ScannerController() {
    cameraController = MobileScannerController(
      formats: [BarcodeFormat.dataMatrix, BarcodeFormat.qrCode],
      autoStart: false,
    );
  }

  void toggleManual() {
    _showManual = !_showManual;
    notifyListeners();
  }

  Future<void> startCamera() async {
    _showManual = false;
    _isCameraActive = true;
    notifyListeners();
    await cameraController.start();
  }

  Future<void> stopCamera() async {
    await cameraController.stop();
    _isCameraActive = false;
    notifyListeners();
  }

  Future<VerificationResult> processRaw(String raw) async {
    _isProcessing = true;
    notifyListeners();

    try {
      if (_isCameraActive) {
        await cameraController.stop();
        _isCameraActive = false;
      }

      final parsed = _parser.parse(raw);
      final isAuthentic = await _crypto.verify(parsed);

      final result = VerificationResult(
        isValid: true,
        isAuthentic: isAuthentic,
        parsedDoc: parsed,
        error: null,
        checkedAt: DateTime.now(),
      );

      _isProcessing = false;
      notifyListeners();
      return result;
    } catch (e) {
      final result = VerificationResult(
        isValid: false,
        isAuthentic: false,
        parsedDoc: null,
        error: e.toString(),
        checkedAt: DateTime.now(),
      );
      
      _isProcessing = false;
      notifyListeners();
      return result;
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
