
class ParsedDoc {
  final String raw;
  final DocHeader header;
  final List<DocField> fields;
  final String signature;

  ParsedDoc({
    required this.raw,
    required this.header,
    required this.fields,
    required this.signature,
  });
}

class DocHeader {
  final String version;
  final String paysEmetteur;
  final String authorityId;
  final String certId;
  final String dateEmission;
  final String paysDoc;
  final String typeDoc;

  DocHeader({
    required this.version,
    required this.paysEmetteur,
    required this.authorityId,
    required this.certId,
    required this.dateEmission,
    required this.paysDoc,
    required this.typeDoc,
  });
}

class DocField {
  final String code;
  final String label;
  final String value;

  DocField({
    required this.code,
    required this.label,
    required this.value,
  });
}

class VerificationResult {
  final bool isValid;
  final bool isAuthentic;
  final ParsedDoc? parsedDoc;
  final String? error;
  final DateTime checkedAt;
  
  // Nouveaux champs backend
  final String? message;
  final String? reference;
  final String? typeDocument;
  final String? statut;

  VerificationResult({
    required this.isValid,
    required this.isAuthentic,
    this.parsedDoc,
    this.error,
    required this.checkedAt,
    this.message,
    this.reference,
    this.typeDocument,
    this.statut,
  });
}