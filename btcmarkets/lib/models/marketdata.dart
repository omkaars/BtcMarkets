import 'package:btcmarkets/helpers/markethelper.dart';

import '../api/btcmarketsapi.dart';

class MarketData extends Market
{
  String name;
  String group;
  int groupId;
  bool isStarred;

  
  double holdings;

  
  String get balanceString => MarketHelper.getValueFormat(instrument, holdings);
  
}