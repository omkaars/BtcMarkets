import 'package:btcmarkets/helpers/markethelper.dart';

import '../api/btcmarketsapi.dart';
import '../constants.dart';

class MarketData extends Market {
  String name;
  String group;
  int groupId;
  bool isStarred;

  double holdings;

  double prevPrice;

  String get prevPriceString =>
      MarketHelper.getValueFormat(instrument, prevPrice);

  double get change {
    double val = 0;
    try {


      var price = prevPrice ?? 0;

      if(price>0)
      {
      val = (lastPrice - price);
      //print(val);
    //  if (price > 0) {
        val /= price;
        val *= 100;
      //}
      }
     

     // print("Change : $prevPrice, $price, $lastPrice, $val");
    } catch (e) {}
    return val;
  }

  DateTime prevPriceDate;

  String get changeString =>
      MarketHelper.getValueFormat(Constants.AUD, change) + "%";
  String get balanceString => MarketHelper.getValueFormat(instrument, holdings);
}
