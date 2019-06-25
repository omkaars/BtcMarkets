
import 'dart:convert';
import 'dart:typed_data';
import "package:hex/hex.dart";

import 'package:pointycastle/pointycastle.dart';

void testSignature() {
  var secret =
      "zE4rPkfizqOYQvbYQhOths6KiS2SyBKI3zRbdbu5qM1ha4VgPu4Om/9zaUAuFm80zGCiVSbSD0NK/ar3BWzpJg==";
  var key = base64.decode(secret);
  final keyParam = new KeyParameter(key);

  var buffer = new StringBuffer();
  buffer.writeln("/account/balance");
  buffer.writeln("1558172923614");
  print(buffer.toString());
  var data = utf8.encode(buffer.toString());

  final mac = new Mac("SHA-512/HMAC");
  mac.init(keyParam);
  var bytes = mac.process(data);

  var signature = base64.encode(bytes);

  print(signature);
}

String encrypt(String password, String data)
{
   var ivStr = "btcmarkets";
  var digest = Digest("SHA-256");

  var key = digest.process(utf8.encode(password));

  var iv = digest.process(utf8.encode(ivStr)).sublist(0,16);

  CipherParameters params = PaddedBlockCipherParameters(ParametersWithIV(KeyParameter(key), iv), null);

   BlockCipher encryptionCipher = new PaddedBlockCipher("AES/CBC/PKCS7");
  encryptionCipher.init(true, params);
  Uint8List encrypted = encryptionCipher.process(utf8.encode(data));

  String encStr = base64Encode(encrypted); //String.fromCharCodes(encrypted);

  return encStr;
}
String decrypt(String password, String encStr)
{
  //var base64 = base64Decode(encStr);
  var data =  base64Decode(encStr);//Uint8List.fromList(encStr.codeUnits);

  var ivStr = "btcmarkets";
  var digest = Digest("SHA-256");
var key = digest.process(utf8.encode(password));

  var iv = digest.process(utf8.encode(ivStr)).sublist(0,16);

  CipherParameters params = PaddedBlockCipherParameters(ParametersWithIV(KeyParameter(key), iv), null);
  BlockCipher decryptionCipher = new PaddedBlockCipher("AES/CBC/PKCS7");
  decryptionCipher.init(false, params);
  String decrypted = utf8.decode(decryptionCipher.process(data));

  return decrypted;
}

Uint8List StringToUint8List( String s ) {
  var ret = new Uint8List(s.length);
  for( var i=0 ; i<s.length ; i++ ) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}

/// UTF16 Decoding
String Uint8ListToString( Uint8List ui ) {
  String s = new String.fromCharCodes(ui);
  return s;
}


void testEncDec(String password, String data)
{
  print("Encryptings");
  var ivStr = "btcmarkets";

  var digest = Digest("SHA-256");

  var key = digest.process(utf8.encode(password));

  var iv = digest.process(utf8.encode(ivStr)).sublist(0,16);

  CipherParameters params = PaddedBlockCipherParameters(ParametersWithIV(KeyParameter(key), iv), null);

   BlockCipher encryptionCipher = new PaddedBlockCipher("AES/CBC/PKCS7");
  encryptionCipher.init(true, params);
  Uint8List encrypted = encryptionCipher.process(utf8.encode(data));

  
  print("Encrypted: \n" + HEX.encode(encrypted));



  ////////////////
  // Decrypting //
  ////////////////

  BlockCipher decryptionCipher = new PaddedBlockCipher("AES/CBC/PKCS7");
  decryptionCipher.init(false, params);
  String decrypted = utf8.decode(decryptionCipher.process(encrypted));

  print("Decrypted: \n$decrypted");
}
