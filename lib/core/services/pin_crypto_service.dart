import 'package:crypt/crypt.dart';
import 'package:flutter/foundation.dart';

String _hashPinInIsolate(String pin) {
  return Crypt.sha256(pin).toString();
}

bool _verifyPinInIsolate(Map<String, String> args) {
  return Crypt(args['hash']!).match(args['pin']!);
}

class PinCryptoService {
  static Future<String> hashPin(String pin) {
    return compute(_hashPinInIsolate, pin);
  }

  static Future<bool> verifyPin(String pin, String savedHash) {
    return compute(_verifyPinInIsolate, {'pin': pin, 'hash': savedHash});
  }
}
