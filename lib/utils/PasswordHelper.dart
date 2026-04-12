import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class PasswordHelper {
  static const String _STATIC_SALT = "MY_APP_UNIQUE_STATIC_SALT";
  static const int _SALT_LENGTH = 16;

  String generateSalt() {
    final Random random = Random.secure();
    final Uint8List saltBytes = Uint8List(_SALT_LENGTH);

    for (int i = 0; i < _SALT_LENGTH; i++) {
      saltBytes[i] = random.nextInt(256);
    }

    return base64Encode(saltBytes);
  }

  String hashPassword(String password) {
    final String combinedInput = _STATIC_SALT + password;

    final List<int> bytes = utf8.encode(combinedInput);

    final Digest digest = sha256.convert(bytes);

    return digest.toString();
  }
}