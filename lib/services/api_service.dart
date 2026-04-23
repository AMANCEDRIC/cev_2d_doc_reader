import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import '../models/api_models.dart';

class ApiService {
  Future<CevApiResponse> verifyDocument(String payload) async {
    try {
      print('🚀 [API] Appel : ${AppConfig.verifyEndpoint}');
      print('📦 [API] Payload envoyé : ${jsonEncode({'datamatrixPayload': payload})}');

      final response = await http.post(
        Uri.parse(AppConfig.verifyEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'datamatrixPayload': payload,
        }),
      ).timeout(AppConfig.apiTimeout);

      print('📡 [API] Status Code : ${response.statusCode}');
      print('📩 [API] Réponse brute : ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 422) {
        // Le backend renvoie 422 pour une signature invalide, mais avec un JSON valide
        return CevApiResponse.fromRawJson(response.body);
      } else {
        return CevApiResponse(
          valide: false,
          message: 'Erreur serveur (${response.statusCode})',
        );
      }
    } catch (e) {
      return CevApiResponse(
        valide: false,
        message: 'Erreur de connexion : Impossible de joindre le serveur.',
      );
    }
  }
}
