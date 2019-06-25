import 'package:btcmarkets/helpers/markethelper.dart';

import '../api/btcmarketsapi.dart';
import '../constants.dart';

class MarketData extends Market
{
  String name;
  String group;
  int groupId;
  bool isStarred;

  double holdings;

  double prevPrice;

  String get prevPriceString => MarketHelper.getValueFormat(instrument, prevPrice); 

  double get change {
    var price = prevPrice??0;
    var val = (lastPrice - price);
    if(price>0)
    {
        val /= price;
    }
    val *= 100;
    return val;
  }

  DateTime prevPriceDate;
  
  String get changeString =>  MarketHelper.getValueFormat(Constants.AUD, change)+"%";
  String get balanceString => MarketHelper.getValueFormat(instrument, holdings);
  
}