import 'package:flutter/material.dart';

class MarketHelper {

  static Map get markets => {
    "btc": "Bitcoin",
    "aud": "Australian Dollar",
    "bchabc": "Bitcoin ABC",
    "bchsv": "Bitcoin SV",
    "bat" : "Basic Attention Token",
    "ltc" : "Litecoin",
    "xrp" : "Ripple",
    "gnt" : "Golem",
    "xlm" : "Stellar",
    "powr" : "Power Ledger",
    "eth" : "Ethereum",
    "etc" : "Ethereum Classic",
    "omg" : "Omise Go",


  };
  static String getMarketName(String code)
  {
    
    String name = markets[code]??"";
    
    return name;
  }
}

