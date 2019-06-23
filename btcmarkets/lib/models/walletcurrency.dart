
import 'package:btcmarkets/helpers/markethelper.dart';

class WalletCurrency{

  int order;
  WalletCurrency({this.order,this.name,this.currency, this.balance, this.pending});

  String currency;
  String name;
  
  double balance;
  String get balanceString => MarketHelper.getValueFormat(currency, balance);

  double pending;
  String get pendingString => MarketHelper.getValueFormat(currency, pending);

  double get total => balance + pending;
}