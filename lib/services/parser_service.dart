import '../models/doc2d_model.dart';

class ParserService {
  static const String _gs = '\x1D'; // Group Separator
  static const String _us = '\x1F'; // Unit Separator

  ParsedDoc parse(String raw) {
    // Remplacement des tags textuels si nécessaire (compatibilité)
    String cleanRaw = raw
        .replaceAll('<GS>', _gs)
        .replaceAll('<US>', _us);

    // ---------------------------------------------------------
    // Structure réelle du 2D-Doc :
    //   [HEADER 22 chars][01val\x1D][02val\x1D]...\x1FXY[SIGNATURE]
    //   - Header : exactement 22 caractères, longueur fixe
    //   - Champs : séparés par GS (\x1D)
    //   - Séparateur payload/signature : US (\x1F) unique dans le doc
    // ---------------------------------------------------------

    if (!cleanRaw.startsWith('DC')) {
      throw Exception('Format 2D-Doc non reconnu (doit commencer par DC)');
    }

    if (!cleanRaw.contains(_us)) {
      throw Exception('Format 2D-Doc non reconnu (séparateur US absent)');
    }

    // 1. Séparer les données de la signature sur le US unique
    final usSplit = cleanRaw.indexOf(_us);
    final dataSection    = cleanRaw.substring(0, usSplit);
    final signaturePart  = cleanRaw.substring(usSplit + 1); // contient "XY<signature>"

    // 2. Extraire le header (24 premiers caractères fixes)
    // DC(2)+version(2)+authority(4)+certId(4)+dateEmission(4)+dateSignature(4)+typeDoc(2)+perimeter(2)=24
    if (dataSection.length < 24) {
      throw Exception('Header 2D-Doc trop court (${dataSection.length} < 24 chars)');
    }
    final headerStr = dataSection.substring(0, 24);
    final header = _parseHeader(headerStr);

    // 3. Extraire les champs de données (tout ce qui suit le header de 24 chars)
    final fieldsSection = dataSection.substring(24);
    final fieldsRaw = fieldsSection.split(_gs);
    final fields = fieldsRaw
        .where((f) => f.length >= 3) // tag (2 chars) + au moins 1 char de valeur
        .map((f) => DocField(
              code: f.substring(0, 2),
              label: _getLabelForCode(f.substring(0, 2)),
              value: f.substring(2),
            ))
        .toList();

    // 4. La signature commence après "XY" (préfixe du bloc signature)
    final signature = signaturePart.startsWith('XY')
        ? signaturePart.substring(2)
        : signaturePart;

    return ParsedDoc(
      raw: cleanRaw,
      header: header,
      fields: fields,
      signature: signature,
    );
  }

  DocHeader _parseHeader(String header) {
    // Header 24 chars : DC(2)+version(2)+authority(4)+certId(4)+dateEmission(4)+dateSignature(4)+typeDoc(2)+perimeter(2)
    final rawDate = header.length >= 16 ? header.substring(12, 16) : '';
    return DocHeader(
      version: header.length >= 4 ? header.substring(2, 4) : '',
      paysEmetteur: header.length >= 6 ? header.substring(4, 6) : '',
      authorityId: header.length >= 8 ? header.substring(4, 8) : '',
      certId: header.length >= 12 ? header.substring(8, 12) : '',
      dateEmission: _decode2DDocDate(rawDate),
      paysDoc: header.length >= 24 ? header.substring(22, 24) : 'N/A',
      typeDoc: header.length >= 22 ? header.substring(20, 22) : 'N/A',
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