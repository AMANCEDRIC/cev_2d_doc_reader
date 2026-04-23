
import 'dart:typed_data';
import 'dart:convert';

class KeyRegistryService {
  static const Map<String, String> _keyRegistry = {
    'CI0300': 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEzsS0xU086O8R8v8uX4Xp3tC1v8uX4Xp3tC1v8uX4Xp3tC1v8uX4Xp3tC1v8uX4Xp3tC1v8uX4Xp3v',
    'FR0001': 'MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEzsS0xU086O8R8v8uX4Xp3tC1v8uX4Xp3tC1v8uX4Xp3tC1v8uX4Xp3tC1v8uX4Xp3tC1v8uX4Xp3v',
  };

  /// Retourne les bytes DER de la clé publique pour un pays/autorité donnés
  Uint8List? getKeyBytes(String paysEmetteur, String authorityId) {
    final keyId = '$paysEmetteur$authorityId';
    final base64Key = _keyRegistry[keyId];
    if (base64Key == null) return null;

    try {
      return base64Decode(base64Key);
    } catch (_) {
      return null;
    }
  }
}