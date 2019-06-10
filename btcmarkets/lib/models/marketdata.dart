import '../api/btcmarketsapi.dart';

class MarketData extends Market
{
  String name;
  String group;
  int groupId;
  bool isStarred;

  String get pair => "$instrument-$currency";
}