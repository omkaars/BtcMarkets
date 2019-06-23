import 'package:flutter/material.dart';

import '../constants.dart';

class MarketHelper {

  static Map get markets => {
    "btc": "Bitcoin",
    "aud": "Australian Dollar",
    "usd": "US Dollar",
    "bch": "Bitcoin Cash",
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
    "fct" : "Factom",
    "maid":"Maid safe",
    "dao" : "Etheruem DAO"
    

  };
  static String getMarketName(String code)
  {
    
    String name = markets[code]??"";
    
    return name;
  }

  static String getValueFormat(String currency, double value)
  {
     String valueString = "";
    if(currency == Constants.AUD)
    {
       valueString = Constants.audFormat.format(value).toString();
    }
    else
    if((currency??"").isNotEmpty)
    { 
      valueString = Constants.btcFormat.format(value).toString();
    }
    return valueString;
  }

  static String getSymbol(String currency)
  {
    String symbol = "";
    if(currency == Constants.AUD)
    {
       symbol = "\$";
    }
    else
    if(currency == Constants.BTC)
    { 
      symbol = "Ƀ";
    }
    return symbol;
  }
  
}

