import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

class CryptoHelper {
 static String encrypt(String password, String data) {
    var ivStr = "btcmarkets";
    var digest = Digest("SHA-256");

    var key = digest.process(utf8.encode(password));

    var iv = digest.process(utf8.encode(ivStr)).sublist(0, 16);

    CipherParameters params = PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(key), iv), null);

    BlockCipher encryptionCipher = new PaddedBlockCipher("AES/CBC/PKCS7");
    encryptionCipher.init(true, params);
    Uint8List encrypted = encryptionCipher.process(utf8.encode(data));

     String encStr = base64Encode(encrypted);

    return encStr;
  }

  static String decrypt(String password, String encStr) {
    var data =  base64Decode(encStr);

    var ivStr = "btcmarkets";
    var digest = Digest("SHA-256");
    var key = digest.process(utf8.encode(password));

    var iv = digest.process(utf8.encode(ivStr)).sublist(0, 16);

    CipherParameters params = PaddedBlockCipherParameters(
        ParametersWithIV(KeyParameter(key), iv), null);
    BlockCipher decryptionCipher = new PaddedBlockCipher("AES/CBC/PKCS7");
    decryptionCipher.init(false, params);
    String decrypted = utf8.decode(decryptionCipher.process(data));

    return decrypted;
  }
}
