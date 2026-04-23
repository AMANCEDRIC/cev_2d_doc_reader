import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/doc2d_model.dart';
import '../services/parser_service.dart';
import '../services/api_service.dart';

class ScannerController extends ChangeNotifier {
  final ParserService _parser = ParserService();
  final ApiService _api = ApiService();
  
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
      // Le scan sur écran est plus stable avec un débit normal + résolution plus élevée.
      cameraResolution: const Size(1280, 720),
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 700,
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
      
      // Appel à l'API Backend pour la vérification avec la charge utile nettoyée
      final apiResponse = await _api.verifyDocument(parsed.raw);

      final result = VerificationResult(
        isValid: true,
        isAuthentic: apiResponse.valide,
        parsedDoc: parsed,
        error: null,
        checkedAt: DateTime.now(),
        message: apiResponse.message,
        reference: apiResponse.reference,
        typeDocument: apiResponse.typeDocument,
        statut: apiResponse.statut,
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
