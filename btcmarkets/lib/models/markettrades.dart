import 'package:btcmarkets/api/btcmarketsapi.dart';
import 'package:btcmarkets/helpers/markethelper.dart';

class MarketOrderData
{
  String currency;
  String instrument;
  double price;
  String get priceString => MarketHelper.getValueFormat(currency, price);
  String get priceSymbol => MarketHelper.getSymbol(currency);

  double amount;
  String get amountString => MarketHelper.getValueFormat(instrument, amount);
  String get amountSymbol => MarketHelper.getSymbol(instrument);

  double get total => price * amount;
  String get totalString => MarketHelper.getValueFormat(currency, total);
  String get totalSymbol => MarketHelper.getSymbol(currency);

  MarketOrderData();

  MarketOrderData.fromOrder(String cur, String inst, OrderData data)
  {
    currency = cur;
    instrument = inst;
     price = data.price;
     amount = data.quantity;
  }
}
class MarketTradeData
{
  
}
class MarketTrades
{
   String currency;
   String instrument;
   int timestamp;
   DateTime dateTime;

   List<MarketOrderData> asks;
   List<MarketOrderData> bids;

   List<MarketTradeData> history;

   MarketTrades(){
     asks = List<MarketOrderData>();
     bids = List<MarketOrderData>();
     history = List<MarketTradeData>();
   }
   
   MarketTrades.fromBook(OrderBook book)
   {
     currency = book.currency;
     instrument = book.instrument;
     timestamp = book.timestamp;
     dateTime = book.datetime;
     if(asks == null)
     {
       asks = new List<MarketOrderData>();
     }
     book.asks.forEach((a){
       asks.add(MarketOrderData.fromOrder(currency, instrument, a));
     });
    if(bids == null)
    {
      bids = new List<MarketOrderData>();
    }
     book.bids.forEach((b){
       bids.add(MarketOrderData.fromOrder(currency, instrument, b));
     });
     
   }
}