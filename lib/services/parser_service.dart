import '../models/doc2d_model.dart';

class ParserService {
  static const String _gs = '\x1D'; // Group Separator
  static const String _us = '\x1F'; // Unit Separator

  ParsedDoc parse(String raw) {
    // Remplacement des tags textuels si nécessaire
    String cleanRaw = raw
        .replaceAll('<GS>', _gs)
        .replaceAll('<US>', _us);

    if (!cleanRaw.contains(_us)) {
      throw Exception('Format 2D-Doc non reconnu (pas de séparateur US)');
    }

    final parts = cleanRaw.split(_us);
    final dataSection = parts[0];
    final signatureB64 = parts.length > 1 ? parts[1] : '';

    final firstGS = dataSection.indexOf(_gs);

    if (firstGS == -1 || !dataSection.startsWith('DC')) {
      throw Exception("Format 2D-Doc non reconnu (pas d'en-tête valide)");
    }

    final headerStr = dataSection.substring(0, firstGS);
    final header = _parseHeader(headerStr);

    final fieldsRaw = dataSection.substring(firstGS + 1).split(_gs);
    final fields = fieldsRaw
        .where((f) => f.length >= 2)
        .map((f) => DocField(
      code: f.substring(0, 2),
      label: _getLabelForCode(f.substring(0, 2)),
      value: f.substring(2),
    ))
        .toList();

    return ParsedDoc(
      raw: cleanRaw,
      header: header,
      fields: fields,
      signature: signatureB64,
    );
  }

  DocHeader _parseHeader(String header) {
    final rawDate = header.length >= 19 ? header.substring(15, 19) : '';
    return DocHeader(
      version: header.length >= 4 ? header.substring(2, 4) : '',
      paysEmetteur: header.length >= 6 ? header.substring(4, 6) : '',
      authorityId: header.length >= 10 ? header.substring(6, 10) : '',
      certId: header.length >= 15 ? header.substring(10, 15) : '',
      dateEmission: _decode2DDocDate(rawDate),
      paysDoc: header.length >= 21 ? header.substring(19, 21) : 'N/A',
      typeDoc: header.length >= 23 ? header.substring(21, 23) : 'N/A',
    );
  }

  String _decode2DDocDate(String hexDate) {
    try {
      final days = int.parse(hexDate, radix: 16);
      final date = DateTime(2000, 1, 1).add(Duration(days: days));
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return hexDate;
    }
  }

  String _getLabelForCode(String code) {
    const labels = {
      '01': 'ID Unique',
      '02': 'Nom / Raison Sociale',
      '03': 'Prénom(s)',
      '04': 'Date de Naissance',
      '05': 'Lieu de Naissance',
      '06': 'Nationalité',
      '07': 'Sexe / Info Compl.',
      '08': "Date d'Expiration",
      '09': 'Autorité de Délivrance',
      '10': 'Adresse / Rue',
      '11': 'Code Postal',
      '12': 'Ville',
      '13': 'Pays de Résidence',
      '20': 'Montant de Facture',
      '21': 'Numéro de Facture',
      '22': 'Date de Facture',
    };
    return labels[code] ?? 'Code $code';
  }
}