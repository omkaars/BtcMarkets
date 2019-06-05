
import 'dart:convert';

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
