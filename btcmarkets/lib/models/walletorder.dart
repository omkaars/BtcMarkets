import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:intl/intl.dart';

class WalletOrder{

  WalletOrder({this.id, this.currency, this.instrument, this.status, this.type, this.side, this.timestamp, this.volume, this.price});

  int id;
  String currency;
  String instrument;
  String status;

  String type;
  String side;

  int timestamp;
  
  String get pair => "$instrument-$currency";

  String get sideType => "$side-$type";
  DateTime get createdTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  String get createdString => DateFormat("dd-MMM-yy hh:mm").format(createdTime);

  double volume;
  String get volumeString => MarketHelper.getValueFormat(currency, volume);
  
  double price;

  String get priceString => MarketHelper.getValueFormat(currency, price);


  double get total => price * volume;

  List<WalletTrade> trades;
}

class WalletTrade{
  int id;
  int timestamp;
    String currency;
DateTime get createdTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
  String get createdString => DateFormat("dd-MMM hh:mm").format(createdTime);

  String description;
 
  
  double volume;
  String get volumeString => MarketHelper.getValueFormat(currency, volume);

  double price;

  String get priceString => MarketHelper.getValueFormat(currency, price);
  String side;
  int fee;
  int orderId;
}