import 'dart:convert';

class CevApiResponse {
  final bool valide;
  final String message;
  final String? reference;
  final String? beneficiaireNom;
  final String? beneficiairePrenom;
  final String? typeDocument;
  final String? dateEmission;
  final String? dateExpiration;
  final String? statut;
  final Map<String, dynamic>? rawData;

  CevApiResponse({
    required this.valide,
    required this.message,
    this.reference,
    this.beneficiaireNom,
    this.beneficiairePrenom,
    this.typeDocument,
    this.dateEmission,
    this.dateExpiration,
    this.statut,
    this.rawData,
  });

  factory CevApiResponse.fromJson(Map<String, dynamic> json) {
    return CevApiResponse(
      valide: json['valide'] ?? false,
      message: json['message'] ?? '',
      reference: json['reference'],
      beneficiaireNom: json['beneficiaireNom'],
      beneficiairePrenom: json['beneficiairePrenom'],
      typeDocument: json['typeDocument'],
      dateEmission: json['dateEmission'],
      dateExpiration: json['dateExpiration'],
      statut: json['statut'],
      rawData: json['rawData'] != null ? Map<String, dynamic>.from(json['rawData']) : null,
    );
  }

  factory CevApiResponse.fromRawJson(String str) => CevApiResponse.fromJson(json.decode(str));
}
