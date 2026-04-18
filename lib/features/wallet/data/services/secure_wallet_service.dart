import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureWalletService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _privateKeyLabel = 'eulalia_private_key';
  static const String _publicKeyLabel = 'eulalia_public_key';
  static const String _didLabel = 'eulalia_did';

  Future<bool> hasWallet() async {
    final key = await _secureStorage.read(key: _privateKeyLabel);
    return key != null;
  }

  Future<String?> getStoredDID() async {
    return await _secureStorage.read(key: _didLabel);
  }

  Future<String?> getStoredPublicKey() async {
    return await _secureStorage.read(key: _publicKeyLabel);
  }

  Future<(String publicKey, String did)?> generateWallet() async {
    try {
      final random = Random.secure();
      final keyParts = <int>[];
      for (var i = 0; i < 32; i++) {
        keyParts.add(random.nextInt(256));
      }
      final privateKey = base64.encode(keyParts);
      
      final hash = sha256.convert(utf8.encode(privateKey));
      final publicKey = hash.toString();
      final did = 'did:eulalia:0x${publicKey.substring(0, 16)}';

      await _secureStorage.write(key: _privateKeyLabel, value: privateKey);
      await _secureStorage.write(key: _publicKeyLabel, value: publicKey);
      await _secureStorage.write(key: _didLabel, value: did);

      return (publicKey, did);
    } catch (e) {
      return null;
    }
  }

  Future<String?> signTransaction(String transactionData) async {
    try {
      final privateKey = await _secureStorage.read(key: _privateKeyLabel);
      if (privateKey == null) return null;

      final key = utf8.encode(privateKey);
      final hmac = Hmac(sha256, key);
      final signature = hmac.convert(utf8.encode(transactionData));
      final signatureHex = signature.toString();

      await _secureStorage.write(
        key: 'last_signature',
        value: signatureHex,
      );

      return signatureHex;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getLastSignature() async {
    return await _secureStorage.read(key: 'last_signature');
  }

  Future<bool> verifySignature(String transactionData, String signature) async {
    try {
      final privateKey = await _secureStorage.read(key: _privateKeyLabel);
      if (privateKey == null) return false;

      final key = utf8.encode(privateKey);
      final hmac = Hmac(sha256, key);
      final expected = hmac.convert(utf8.encode(transactionData)).toString();
      
      return expected == signature;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteWallet() async {
    await _secureStorage.delete(key: _privateKeyLabel);
    await _secureStorage.delete(key: _publicKeyLabel);
    await _secureStorage.delete(key: _didLabel);
    await _secureStorage.delete(key: 'last_signature');
  }
}