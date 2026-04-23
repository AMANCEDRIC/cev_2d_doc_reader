
import 'dart:typed_data';
import 'dart:convert';
import 'package:pointycastle/export.dart';
import '../models/doc2d_model.dart';
import 'key_registry_service.dart';

class CryptoService {
  final KeyRegistryService _keyRegistry = KeyRegistryService();

  Future<bool> verify(ParsedDoc doc) async {
    try {
      final keyBytes = _keyRegistry.getKeyBytes(
        doc.header.paysEmetteur,
        doc.header.authorityId,
      );

      if (keyBytes == null) {
        throw Exception('Clé publique introuvable pour ${doc.header.paysEmetteur}${doc.header.authorityId}');
      }

      // Message signé = tout ce qui est AVANT le séparateur US
      final message = doc.raw.split('\x1F')[0];
      final msgBytes = Uint8List.fromList(utf8.encode(message));

      // Décoder la signature Base32
      Uint8List sigBytes;
      try {
        sigBytes = _base32ToBytes(doc.signature);
      } catch (_) {
        // Fallback Base64
        sigBytes = base64Decode(doc.signature);
      }

      // Importer la clé publique ECDSA P-256 depuis DER
      final publicKey = _importECPublicKey(keyBytes);

      // Vérifier la signature ECDSA avec SHA-256
      final signer = Signer('SHA-256/ECDSA');
      signer.init(false, PublicKeyParameter<ECPublicKey>(publicKey));

      // Parser la signature DER ASN.1 en (r, s)
      final ecSig = _parseECSignature(sigBytes);
      return signer.verifySignature(msgBytes, ecSig);
    } catch (e) {
      return false;
    }
  }

  ECPublicKey _importECPublicKey(Uint8List derBytes) {
    // Extraire les 65 bytes du point EC depuis l'enveloppe SPKI DER
    // Format: 04 || X (32 bytes) || Y (32 bytes)
    final offset = derBytes.length - 65;
    final pointBytes = derBytes.sublist(offset);

    final domainParams = ECDomainParameters('prime256v1');
    final point = domainParams.curve.decodePoint(pointBytes)!;
    return ECPublicKey(point, domainParams);
  }

  ECSignature _parseECSignature(Uint8List sigBytes) {
    // Signature brute = r (32 bytes) || s (32 bytes)
    if (sigBytes.length == 64) {
      final r = _bytesToBigInt(sigBytes.sublist(0, 32));
      final s = _bytesToBigInt(sigBytes.sublist(32, 64));
      return ECSignature(r, s);
    }
    // Sinon format DER ASN.1
    return _parseDERSignature(sigBytes);
  }

  ECSignature _parseDERSignature(Uint8List der) {
    int idx = 2; // skip SEQUENCE tag + length
    idx++; // skip INTEGER tag
    int rLen = der[idx++];
    if (der[idx] == 0x00) { idx++; rLen--; } // skip leading zero
    final r = _bytesToBigInt(der.sublist(idx, idx + rLen));
    idx += rLen;
    idx++; // skip INTEGER tag
    int sLen = der[idx++];
    if (der[idx] == 0x00) { idx++; sLen--; }
    final s = _bytesToBigInt(der.sublist(idx, idx + sLen));
    return ECSignature(r, s);
  }

  BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }

  Uint8List _base32ToBytes(String base32) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final clean = base32.replaceAll('=', '').toUpperCase();
    final output = <int>[];
    int bits = 0;
    int value = 0;

    for (final char in clean.split('')) {
      final idx = alphabet.indexOf(char);
      if (idx == -1) throw Exception('Caractère Base32 invalide: $char');
      value = (value << 5) | idx;
      bits += 5;
      if (bits >= 8) {
        output.add((value >> (bits - 8)) & 255);
        bits -= 8;
      }
    }
    return Uint8List.fromList(output);
  }
}