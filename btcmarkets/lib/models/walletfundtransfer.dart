import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:intl/intl.dart';

class WalletFundTransfer
{
  int id;
  String currency;
  String description;
  String status;
  
  int timestamp;
  DateTime get transferTime => DateTime.fromMillisecondsSinceEpoch(timestamp);
  String get transferTimeString => DateFormat("dd-MMM-yy HH:mm").format(transferTime);
  
  int lastUpdate;
  DateTime get lastUpdateTime => DateTime.fromMillisecondsSinceEpoch(lastUpdate);
  String get lastUpdateString => DateFormat("dd-MMM-yy h:mm").format(lastUpdateTime);
  

  double amount;
  String get amountString => MarketHelper.getValueFormat(currency, amount);
  
  double fee;
  String get feeString => MarketHelper.getValueFormat(currency, fee);

  String transferType;
  
  String txid;
  String address;
}