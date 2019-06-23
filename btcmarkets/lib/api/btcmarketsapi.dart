import 'dart:io';

import 'package:btcmarkets/constants.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:async';
import "package:pointycastle/pointycastle.dart";
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

class ApiConstants {
  static const double CurrencyDecimal = 100000000;
}

class ApiResponse {
  bool success;
  int errorCode;
  String errorMessage;
}

class ActiveMarket {
  String instrument;

  String currency;

  ActiveMarket.fromJson(json)
      : instrument = json['instrument'],
        currency = json['currency'];

  Map<String, dynamic> toJson() =>
      {'instrument': instrument, 'currency': currency};
}

class ActiveMarkets extends ApiResponse {
  List<ActiveMarket> activeMarkets = new List<ActiveMarket>();

  ActiveMarkets() {}

  ActiveMarkets.fromJson(data) {
    try {
      success = data['success'];
      errorCode = data['errorCode'];
      errorMessage = data['errorMessage'];

      var markets = data['markets'];
      if (markets != null) {
        for (var market in markets) {
          activeMarkets.add(ActiveMarket.fromJson(market));
        }
      }
    } catch (e) {
      success = false;
      errorMessage = e.toString();
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'markets': activeMarkets
    };
  }
}

class Tick extends ApiResponse {
  double bestBid;

  double bestAsk;

  double lastPrice;

  String currency;

  String instrument;

  int timestamp;

  double volume24h;

  Tick() {}
  Tick.fromJson(data) {
    try {
      bool successFlag;
      try {
        successFlag = data['success'];
      } catch (e) {}
      if (successFlag == null) {
        success = true;

        instrument = data['instrument'];
        currency = data['currency'];
        bestBid = data['bestBid'];
        bestAsk = data['bestAsk'];
        lastPrice = data['lastPrice'];
        timestamp = data['timestamp'];
        volume24h = data['volume24h'];
      } else {
        success = data['success'];
        errorCode = data['errorCode'];
        errorMessage = data['errorMessage'];
      }
    } catch (jex) {
      success = false;
      errorCode = 101;
      errorMessage = jex.toString();
    }
  }
  Map<String, dynamic> toJson() => {
        'success': success,
        'errorCode': errorCode,
        'errorMessage': errorMessage,
        'instrument': instrument,
        'currency': currency,
        'bestBid': bestBid,
        'bestAsk': bestAsk,
        'lastPrice': lastPrice,
        'timestamp': timestamp,
        'volume24h': volume24h
      };
}

class Market {
  double bestBid;

  double bestAsk;

  double lastPrice;

  String currency;

  String instrument;

  int timestamp;

  DateTime get lastUpdateDate =>
      DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  double volume24h;

  String get pair => "$instrument-$currency";

  String get priceString => getValueFormat(lastPrice);
  String get priceSymbolString => "${getSymbol()}$lastPrice";

  String get bidString => getValueFormat(bestBid);
  String get bidSymbolString => "${getSymbol()}$bestBid";

  String get askString => getValueFormat(bestAsk);
  String get askSymbolString => "${getSymbol()}$bestAsk";

  String getSymbol()
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

  String getValueFormat(double value)
  {
     String valueString = "";
    if(currency == Constants.AUD)
    {
       valueString = Constants.audFormat.format(value).toString();
    }
    else
    if(currency == Constants.BTC)
    { 
      valueString = Constants.btcFormat.format(value).toString();
    }
    return valueString;
  }

  Market() {}
  Market.fromTick(Tick tick) {
    if (tick == null) return;
    instrument = tick.instrument;
    currency = tick.currency;
    bestBid = tick.bestBid;
    bestAsk = tick.bestAsk;
    lastPrice = tick.lastPrice;
    timestamp = tick.timestamp;
    volume24h = tick.volume24h;
  }

  Market.fromJson(data) {
    instrument = data['instrument'];
    currency = data['currency'];
    bestBid = data['bestBid'];
    bestAsk = data['bestAsk'];
    lastPrice = data['lastPrice'];
    timestamp = data['timestamp'];
    volume24h = data['volume24h'];
  }
  Map<String, dynamic> toJson() => {
        'instrument': instrument,
        'currency': currency,
        'bestBid': bestBid,
        'bestAsk': bestAsk,
        'lastPrice': lastPrice,
        'timestamp': timestamp,
        'lastUpdateDate': lastUpdateDate?.toString(),
        'volume24h': volume24h
      };
}

class Markets extends ApiResponse {
  List<Market> markets = new List<Market>();
  Markets() {}
  Markets.fromJson(data) {
    try {
      success = data['success'];
      errorCode = data['errorCode'];
      errorMessage = data['errorMessage'];
    } catch (e) {
      success = false;
      errorCode = 101;
      errorMessage = e.toString();
    }
  }
  Map<String, dynamic> toJson() {
    var jsonData = {
      'success': success,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'markets': markets
    };
    return jsonData;
  }
}

class AccountBalance {
  int balance;
  int pendingFunds;
  String currency;
  
  double get balanceValue =>
      balance > 0 ? (balance / ApiConstants.CurrencyDecimal) : 0;
  
  double get pendingFundsValue =>
      pendingFunds > 0 ? (pendingFunds / ApiConstants.CurrencyDecimal) : 0;

  AccountBalance.fromJson(json)
      : balance = json['balance'],
        pendingFunds = json['pendingFunds'],
        currency = json['currency'];

  Map<String, dynamic> toJson() => {
        'balance': balance,
        'pendingFunds': pendingFunds,
        'currency': currency,
        'balanceValue': balanceValue
      };
}

class AccountBalances extends ApiResponse {
  List<AccountBalance> balances = new List<AccountBalance>();

  AccountBalances() {}
  AccountBalances.fromJson(jsonData) {
    try {
      bool successFlag;
      try {
        successFlag = jsonData['success'];
      } catch (e) {}

      if (successFlag == null) {
        this.success = true;
        for (var data in jsonData) {
          balances.add(AccountBalance.fromJson(data));
        }
      } else {
        this.success = false;
        this.errorCode = jsonData['errorCode'];
        this.errorMessage = jsonData['errorMessage'];
      }
    } catch (bex) {
      this.success = false;
      this.errorMessage = bex.toString();
    }
  }

  Map<String, dynamic> toJson() {
    var jsonData = {
      'success': success,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'balances': balances
    };
    return jsonData;
  }
}

class TradingFee extends ApiResponse {
  int tradingFeeRate;
  int volume30Day;
  int makerTradingFeeRate;
  int takerTradingFreeRate;

  double get volume30DayValue =>
      (volume30Day ?? 0) > 0 ? (volume30Day / ApiConstants.CurrencyDecimal) : 0;
  double get tradingFeeRateValue => (tradingFeeRate ?? 0) > 0
      ? (tradingFeeRate / ApiConstants.CurrencyDecimal)
      : 0;
  double get makerTradingFeeRateValue => (makerTradingFeeRate ?? 0) > 0
      ? (makerTradingFeeRate / ApiConstants.CurrencyDecimal)
      : 0;
  double get takerTradingFreeRateValue => (takerTradingFreeRate ?? 0) > 0
      ? (takerTradingFreeRate / ApiConstants.CurrencyDecimal)
      : 0;

  TradingFee() {}

  TradingFee.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    tradingFeeRate = json['tradingFeeRate'];
    volume30Day = json['volume30Day'];
    makerTradingFeeRate = json['makerTradingFeeRate'];
    takerTradingFreeRate = json['takerTradingFreeRate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    data['tradingFeeRate'] = this.tradingFeeRate;
    data['volume30Day'] = this.volume30Day;
    data['makerTradingFeeRate'] = this.makerTradingFeeRate;
    data['takerTradingFreeRate'] = this.takerTradingFreeRate;
    data['volume30DayValue'] = this.volume30DayValue;
    data['tradingFeeRateValue'] = this.tradingFeeRateValue;
    data['makerTradingFeeRateValue'] = this.makerTradingFeeRateValue;
    data['takerTradingFreeRateValue'] = this.takerTradingFreeRateValue;
    return data;
  }
}


class Trades {
  int id;
  int creationTime;
  String description;
  int price;
  int volume;
  String side;
  int fee;
  int orderId;

  double get priceValue =>
      price > 0 ? (price / ApiConstants.CurrencyDecimal) : 0;

  double get volumeValue =>
      volume > 0 ? (volume / ApiConstants.CurrencyDecimal) : 0;

  
  double get feeValue =>
      fee > 0 ? (fee / ApiConstants.CurrencyDecimal) : 0;

  Trades(
      {this.id,
      this.creationTime,
      this.description,
      this.price,
      this.volume,
      this.side,
      this.fee,
      this.orderId});

  Trades.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    creationTime = json['creationTime'];
    description = json['description'];
    price = json['price'];
    volume = json['volume'];
    side = json['side'];
    fee = json['fee'];
    orderId = json['orderId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['creationTime'] = this.creationTime;
    data['description'] = this.description;
    data['price'] = this.price;
    data['volume'] = this.volume;
    data['side'] = this.side;
    data['fee'] = this.fee;
    data['orderId'] = this.orderId;
    return data;
  }
}

class Orders {
  int id;
  String currency;
  String instrument;
  String orderSide;
  String ordertype;
  int creationTime;
  String status;
  String errorMessage;
  int price;
  int volume;

  double get priceValue =>
      price > 0 ? (price / ApiConstants.CurrencyDecimal) : 0;

  double get volumeValue =>
      volume > 0 ? (volume / ApiConstants.CurrencyDecimal) : 0;

  int openVolume;
  String clientRequestId;
  List<Trades> trades;

  Orders(
      {this.id,
      this.currency,
      this.instrument,
      this.orderSide,
      this.ordertype,
      this.creationTime,
      this.status,
      this.errorMessage,
      this.price,
      this.volume,
      this.openVolume,
      this.clientRequestId,
      this.trades});

  Orders.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currency = json['currency'];
    instrument = json['instrument'];
    orderSide = json['orderSide'];
    ordertype = json['ordertype'];
    creationTime = json['creationTime'];
    status = json['status'];
    errorMessage = json['errorMessage'];
    price = json['price'];
    volume = json['volume'];
    openVolume = json['openVolume'];
    clientRequestId = json['clientRequestId'];
    if (json['trades'] != null) {
      trades = new List<Trades>();
      json['trades'].forEach((v) {
        trades.add(new Trades.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['currency'] = this.currency;
    data['instrument'] = this.instrument;
    data['orderSide'] = this.orderSide;
    data['ordertype'] = this.ordertype;
    data['creationTime'] = this.creationTime;
    data['status'] = this.status;
    data['errorMessage'] = this.errorMessage;
    data['price'] = this.price;
    data['volume'] = this.volume;
     data['priceValue'] = this.priceValue;
    data['volumeValue'] = this.volumeValue;
    data['openVolume'] = this.openVolume;
    data['clientRequestId'] = this.clientRequestId;
    if (this.trades != null) {
      data['trades'] = this.trades.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class OrderHistory {
  bool success;
  String errorCode;
  String errorMessage;
  List<Orders> orders;
  Paging paging;

  OrderHistory(
      {this.success,
      this.errorCode,
      this.errorMessage,
      this.orders,
      this.paging});

  OrderHistory.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    if (json['orders'] != null) {
      orders = new List<Orders>();
      json['orders'].forEach((v) {
        orders.add(new Orders.fromJson(v));
      });
    }
    paging =
        json['paging'] != null ? new Paging.fromJson(json['paging']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    if (this.orders != null) {
      data['orders'] = this.orders.map((v) => v.toJson()).toList();
    }
    if (this.paging != null) {
      data['paging'] = this.paging.toJson();
    }
    return data;
  }
}


class TradeHistory {
  bool success;
  String errorCode;
  String errorMessage;
  List<Trades> trades;
  Paging paging;

  TradeHistory(
      {this.success,
      this.errorCode,
      this.errorMessage,
      this.trades,
      this.paging});

  TradeHistory.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    if (json['trades'] != null) {
      trades = new List<Trades>();
      json['trades'].forEach((v) {
        trades.add(new Trades.fromJson(v));
      });
    }
    paging =
        json['paging'] != null ? new Paging.fromJson(json['paging']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    if (this.trades != null) {
      data['trades'] = this.trades.map((v) => v.toJson()).toList();
    }
    if (this.paging != null) {
      data['paging'] = this.paging.toJson();
    }
    return data;
  }
}

class OpenOrders {
  bool success;
  String errorCode;
  String errorMessage;
  List<Orders> orders;

  OpenOrders({this.success, this.errorCode, this.errorMessage, this.orders});

  OpenOrders.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    if (json['orders'] != null) {
      orders = new List<Orders>();
      json['orders'].forEach((v) {
        orders.add(new Orders.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    if (this.orders != null) {
      data['orders'] = this.orders.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FundTransferHistory {
  bool success;
  String errorCode;
  String errorMessage;
  List<FundTransfer> fundTransfers;

  FundTransferHistory(
      {this.success, this.errorCode, this.errorMessage, this.fundTransfers});

  FundTransferHistory.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    if (json['fundTransfers'] != null) {
      fundTransfers = new List<FundTransfer>();
      json['fundTransfers'].forEach((v) {
        fundTransfers.add(new FundTransfer.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    if (this.fundTransfers != null) {
      data['fundTransfers'] =
          this.fundTransfers.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FundTransfer {
  String status;
  int fundTransferId;
  String description;
  int creationTime;
  String currency;
  int amount;
  double get amountValue =>    amount > 0 ? (amount / ApiConstants.CurrencyDecimal) : 0;
  int fee;
  double get feeValue =>    fee > 0 ? (fee / ApiConstants.CurrencyDecimal) : 0;
  
  String transferType;
  String errorMessage;
  int lastUpdate;
  dynamic cryptoPaymentDetail;

  FundTransfer(
      {this.status,
      this.fundTransferId,
      this.description,
      this.creationTime,
      this.currency,
      this.amount,
      this.fee,
      this.transferType,
      this.errorMessage,
      this.lastUpdate,
      this.cryptoPaymentDetail});

  FundTransfer.fromJson(Map<String, dynamic> json) {
      status = json['status'];
    fundTransferId = json['fundTransferId'];
    description = json['description'];
    creationTime = json['creationTime'];
    currency = json['currency'];
    amount = json['amount'];
    fee = json['fee'];
    transferType = json['transferType'];
    errorMessage = json['errorMessage'];
    lastUpdate = json['lastUpdate'];
    cryptoPaymentDetail = json['cryptoPaymentDetail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['fundTransferId'] = this.fundTransferId;
    data['description'] = this.description;
    data['creationTime'] = this.creationTime;
    data['currency'] = this.currency;
    data['amount'] = this.amount;
    data['fee'] = this.fee;
    data['transferType'] = this.transferType;
    data['errorMessage'] = this.errorMessage;
    data['lastUpdate'] = this.lastUpdate;
    data['cryptoPaymentDetail'] = this.cryptoPaymentDetail;
    return data;
  }
}
class CryptoAddress {
  bool success;
  String errorCode;
  String errorMessage;
  String address;
  String currency;

  CryptoAddress(
      {this.success,
      this.errorCode,
      this.errorMessage,
      this.address,
      this.currency});

  CryptoAddress.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    address = json['address'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    data['address'] = this.address;
    data['currency'] = this.currency;
    return data;
  }
}
class WithdrawalFee {
  bool success;
  String errorCode;
  String errorMessage;
  int fee;
  String currency;

  WithdrawalFee(
      {this.success,
      this.errorCode,
      this.errorMessage,
      this.fee,
      this.currency});

  WithdrawalFee.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    fee = json['fee'];
    currency = json['currency'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    data['fee'] = this.fee;
    data['currency'] = this.currency;
    return data;
  }
}
class FundTransferData {
  bool success;
  Null errorCode;
  Null errorMessage;
  FundTransfer fundtransfer;

  FundTransferData(
      {this.success, this.errorCode, this.errorMessage, this.fundtransfer});

  FundTransferData.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    errorCode = json['errorCode'];
    errorMessage = json['errorMessage'];
    fundtransfer = json['fundtransfer'] != null
        ? new FundTransfer.fromJson(json['fundtransfer'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['errorCode'] = this.errorCode;
    data['errorMessage'] = this.errorMessage;
    if (this.fundtransfer != null) {
      data['fundtransfer'] = this.fundtransfer.toJson();
    }
    return data;
  }
}
enum TickTime
{
  minute,
  hour,
  day,
}

class Paging
{
   Paging();

   String newer;
   String older;

   Paging.fromJson(json)
    : newer = json['newer'],
      older = json['older'];

   Map<String, dynamic> toJson() => 
   {
     "newer" : newer,
     "older" : older
   };
}

class HistoricalTick 
{

  int timeStamp;
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timeStamp);

  int open;
  double get openValue => open > 0 ? (open / ApiConstants.CurrencyDecimal) : 0;

  int high;
  double get highValue => high > 0 ? (high / ApiConstants.CurrencyDecimal) : 0;
  
  int low;
  double get lowValue => low > 0 ? (low / ApiConstants.CurrencyDecimal) : 0;

  int close;
  double get closeValue => close > 0 ? (close / ApiConstants.CurrencyDecimal) : 0;

  int volume;
  double get volumeValue => volume > 0 ? (volume / ApiConstants.CurrencyDecimal) : 0;


  HistoricalTick.fromJson(json)
      : timeStamp = json['timestamp'],
        open = json['open'],
        high = json['high'],
        low  = json['low'],
        close = json['close'],
        volume = json['volume'];

  Map<String, dynamic> toJson() => {
        'timestamp': timeStamp,
        'dateTime' : dateTime,
        'open': open,
        'openValue':openValue,
        'high': high,
        'highValue': highValue,
        'low' : low,
        'lowValue':lowValue,
        'close' : close,
        'closeValue': closeValue,
        'volume' : volume,
        'volumeValue': volumeValue
      };
}
class HistoricalTicks extends ApiResponse {
  Paging paging = new Paging();
  List<HistoricalTick> ticks = new List<HistoricalTick>();

  HistoricalTicks() {}
  HistoricalTicks.fromJson(jsonData) {
    try {
      bool successFlag;
      
      try {
        successFlag = jsonData['success'];
      } catch (e) {}

      if (successFlag) {
        this.success = true;
        
        var pager = jsonData['paging'];
        paging = Paging.fromJson(pager);

        var jsonTicks = jsonData['ticks'];
        for (var data in jsonTicks) {
          ticks.add(HistoricalTick.fromJson(data));
        }
      } else {
        this.success = false;
        this.errorCode = jsonData['errorCode'];
        this.errorMessage = jsonData['errorMessage'];
      }
    } catch (bex) {
      this.success = false;
      this.errorMessage = bex.toString();
    }
  }

  Map<String, dynamic> toJson() {
    var jsonData = {
      'success': success,
      'errorCode': errorCode,
      'errorMessage': errorMessage,
      'paging' : paging,
      'ticks': ticks
    };
    return jsonData;
  }
}


class OrderData
{
  double price;
  double quantity;
  double get total => price * quantity;

  OrderData();

  OrderData.fromJson(json)
  {

     price = json[0];
     quantity = json[1];
  }
  Map<String, dynamic> toJson() {
    
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["price"] = this.price;
    data["quantity"] = this.quantity;
    data["total"] = this.total;
    
    return data;
  }
  

}
class OrderBook extends ApiResponse
{
  String currency;
  String instrument;

  int timestamp;
  
  DateTime get datetime => DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);

  List<OrderData> asks;

  List<OrderData> bids;

  OrderBook();

  OrderBook.fromJson(Map<String, dynamic> json) {
    currency = json['currency'];
    instrument = json['instrument'];
    timestamp = json['timestamp'];
   
    if(asks == null)
    {
      asks = new List<OrderData>();
    }

    if(bids == null)
    {
      bids = new List<OrderData>();
    }
    
    for(var ask in json['asks'])
    {
      var data = OrderData.fromJson(ask);
      asks.add(data);
    } 

    for(var bid in json['bids'])
    {
      var data = OrderData.fromJson(bid);
      bids.add(data);
    } 
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["currency"] = this.currency;
    data["instrument"] = this.instrument;
    data["timestamp"] = this.timestamp;
    data["datetime"] = this.datetime;
   
    var askArr = [];
    asks.forEach((f){
      askArr.add(f.toJson());
    });
    var askStr = askArr.join(",");
    data["asks"] = "[$askStr]";

    var bidArr = [];
    bids.forEach((f){
      bidArr.add(f.toJson());
    });
    var bidStr = bidArr.join(",");
    data["bids"] = "[$bidStr]";
    
    return data;
  }
}

class BtcMarketsApi {
  static final BtcMarketsApi _api = new BtcMarketsApi._internal();

  factory BtcMarketsApi() {
    return _api;
  }

  BtcMarketsApi._internal() {
    _baseUrl = "https://api.btcmarkets.net";

    _dio = new Dio();
    _dio.interceptors.add(InterceptorsWrapper(
        onRequest: (RequestOptions options) {
          var path = options.uri.path;
          var method = options.method;
          var query = options.uri.query;
          var timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;

          options.headers["Accept"] = "*/*";
          options.headers["Accept-Charset"] = "UTF-8";
          options.headers["Content-Type"] = "application/json";
          options.headers["timestamp"] = timestamp;

          if (_apiKey != null && _apiKey.isNotEmpty) {
            options.headers["apikey"] = _apiKey;
          }

          var buffer = new StringBuffer();

          buffer.writeln(path);

          if (query != null && query.isNotEmpty) {
            buffer.writeln(query);
          }
          buffer.writeln(timestamp);
          if (method == "POST" && options.data != null) {
            var postData = options.data.toString();
            if (postData != null && postData.isNotEmpty) {
              buffer.write(options.data.toString());
            }
          }

          if (_secret != null && _secret.isNotEmpty) {
            try {
              var key = base64.decode(_secret);
              final keyParam = new KeyParameter(key);

              var data = utf8.encode(buffer.toString());
              final mac = new Mac("SHA-512/HMAC");
              mac.init(keyParam);
              var bytes = mac.process(data);

              var signature = base64.encode(bytes);

              if (signature != null && signature.isNotEmpty) {
                options.headers["signature"] = signature;
              }
            } catch (e) {}
          }
        },
        onError: (DioError e) {}));
  }

  Dio _dio;

  String _baseUrl;
  String _apiKey;
  String _secret;

  void updateCredentials(apiKey, secret) {
    _apiKey = apiKey;
    _secret = secret;
  }
  /**
   * Gets all the active markets
   * 
   */

  Future<ActiveMarkets> getActiveMarkets() async {
    ActiveMarkets markets = new ActiveMarkets();

    try {
      var response = await _dio.get("${_baseUrl}/v2/market/active");

      var data = response.data;
      var obj = ActiveMarkets.fromJson(data);
      if (obj != null) {
        markets = obj;
      }
    } catch (e) {
      markets.success = false;
      markets.errorCode = 101;
      markets.errorMessage = e.toString();
    }

    return markets;
  }

  /*
   *  Gets all the markets
   *
   */
  Future<Markets> getMarkets({List<ActiveMarket> activeMarkets}) async {
    Markets markets = new Markets();

    try {

      if(activeMarkets == null || activeMarkets.isEmpty)
      {
        var data = await getActiveMarkets();
        if(data.success)
        {
          activeMarkets = data.activeMarkets;
        }
      }
        if (activeMarkets != null && activeMarkets.isNotEmpty) {
      
      
          for (var activeMarket in activeMarkets) {
            var tick =
                await getTick(activeMarket.instrument, activeMarket.currency);

            if (tick != null && tick.success) {
              markets.markets.add(Market.fromTick(tick));
            }
          }
        
      }
      markets.success = true;
    } catch (e) {
      markets.success = false;
      markets.errorCode = 101;
      markets.errorMessage = e.toString();
    }

    return markets;
  }

  /*
   *  Gets market tick of given instrument and currency
   * 
   */
  Future<Tick> getTick(instrument, currency) async {
    Tick tick = new Tick();

    try {
      instrument ??= "BTC";

      currency ??= "AUD";

      var response =
          await _dio.get("${_baseUrl}/market/${instrument}/${currency}/tick");

      tick = Tick.fromJson(response.data);
    } catch (e) {
      tick.success = false;
      tick.errorCode = 101;
      tick.errorMessage = e.toString();
    }

    return tick;
  }

Future<HistoricalTicks> getHistoricalTicks(String instrument, String currency, TickTime tickTime, DateTime since, bool forward) async {
    HistoricalTicks ticks = new HistoricalTicks();

    try {
      instrument ??= "BTC";

      currency ??= "AUD";

      String timeSpan;
      switch(tickTime)
      {
        case TickTime.day:{
          timeSpan = "day";
        }
        break;
        case TickTime.hour:
        {
          timeSpan = "hour";
        }
        break;
        default:
          timeSpan = "minute";
          break;
      }

      int sinceTime = since.millisecondsSinceEpoch;

      var response =
          await _dio.get("${_baseUrl}/v2/market/${instrument}/${currency}/tickByTime/$timeSpan?since=$sinceTime&indexForward=$forward");

      ticks = HistoricalTicks.fromJson(response.data);

    } catch (e) {
      ticks.success = false;
      ticks.errorCode = 101;
      ticks.errorMessage = e.toString();
    }

    return ticks;
  }

  Future<OrderBook> getOrderBook(String instrument, String currency) async
  {
      OrderBook book = new OrderBook();

      try {
      var response = await _dio.get("$_baseUrl/market/$instrument/$currency/orderbook");
      
      var obj = OrderBook.fromJson(response.data);
      
      if (obj != null) {
        book = obj;
        book.success = true;
      }
    } catch (e) {
      book.success = false;
      book.errorMessage = e.toString();
    }
      return book;
  }

  /*
   *  Gets the account balance.
   */
  Future<AccountBalances> getAccountBalances() async {
    AccountBalances balances = new AccountBalances();

    try {
      var response = await _dio.get("${_baseUrl}/account/balance");

      var obj = AccountBalances.fromJson(response.data);
      if (obj != null) {
        balances = obj;
      }
    } catch (e) {
      balances.success = false;
      balances.errorMessage = e.toString();
    }

    return balances;
  }

  /**
   *  Gets the order history
   */
  Future<OrderHistory> getOrderHistory(String instrument, String currency, {String since, String forward}) async {
    OrderHistory history = new OrderHistory();
   

    try {
      var url = "${_baseUrl}/v2/order/history/${instrument}/${currency}";
      
      var params = new StringBuffer();
      if(since != null)
      {
          params.write("since=$since");
      }
      if(forward != null)
      {
        params.write("forward=$forward");
      }
      if(params.isNotEmpty)
      {
        url = url +"?${params.toString()}";
      }
      var response = await _dio.get(url);
      print(response.data);
      var obj = OrderHistory.fromJson(response.data);
      if (obj != null) {
        history = obj;
      }
    } catch (e) {
      print(e);
      history.success = false;
      history.errorMessage = e.toString();
    }

    return history;
  }

   /**
   *  Gets the order history
   */
  Future<TradeHistory> getTradeHistory(String instrument, String currency) async {
    TradeHistory history = new TradeHistory();
   

    try {
      var url = "${_baseUrl}/v2/market/${instrument}/${currency}/trades";
      
    
      var response = await _dio.get(url);
      print(response.data);
      var obj = TradeHistory.fromJson(response.data);
      if (obj != null) {
        history = obj;
      }
    } catch (e) {
      print(e);
      history.success = false;
      history.errorMessage = e.toString();
    }

    return history;
  }

   /**
   *  Gets the order history
   */
  Future<OpenOrders> getOpenOrders({String instrument, String currency}) async {
    OpenOrders history = new OpenOrders();
   

    try {
      var url = "${_baseUrl}/v2/order/open";
       var params = new StringBuffer();
      if(instrument != null)
      {
          params.write("instrument=$instrument");
      }
      if(currency != null)
      {
        params.write("currency=$currency");
      }
      if(params.isNotEmpty)
      {
        url = url +"?${params.toString()}";
      }
    
      var response = await _dio.get(url);
      
      var obj = OpenOrders.fromJson(response.data);
      if (obj != null) {
        history = obj;
      }
    } catch (e) {
      print(e);
      history.success = false;
      history.errorMessage = e.toString();
    }

    return history;
  }

  /**
   *  Gets the order history
   */
  Future<FundTransferHistory> getFundTransferHistory({String since, String forward}) async {
    FundTransferHistory history = new FundTransferHistory();
   

    try {
      var url = "${_baseUrl}/fundtransfer/history";
      
      var params = new StringBuffer();
      if(since != null)
      {
          params.write("since=$since");
      }
      if(forward != null)
      {
        params.write("forward=$forward");
      }
      if(params.isNotEmpty)
      {
        url = url +"?${params.toString()}";
      }
      var response = await _dio.get(url);
      
      var obj = FundTransferHistory.fromJson(response.data);
      if (obj != null) {
        history = obj;
      }
    } catch (e) {
      print(e);
      history.success = false;
      history.errorMessage = e.toString();
    }

    return history;
  }

  Future<CryptoAddress> getDepositAddress(String instrument) async {
    CryptoAddress address = new CryptoAddress();

    try {
      var response = await _dio
          .get("${_baseUrl}/v2/fundtransfer/deposit/address/${instrument}");

      var data = response.data;
      var addr = CryptoAddress.fromJson(data);
      if (addr != null) {
        address = addr;
      }
    } catch (e) {
      address.success = false;
      address.errorMessage = e.toString();
    }

    return address;
  }
  
  Future<WithdrawalFee> getWithdrawalFee(String instrument) async {
    WithdrawalFee withFee = new WithdrawalFee();

    try {
      var response = await _dio
          .get("${_baseUrl}/v2/fundtransfer/withdrawal/fee/${instrument}");

      var data = response.data;
      var fee = WithdrawalFee.fromJson(data);
      if (fee != null) {
        withFee = fee;
      }
    } catch (e) {
      withFee.success = false;
      withFee.errorMessage = e.toString();
    }

    return withFee;
  }

  Future<FundTransferData> getFundTransfer(int fundTransferId) async {
    FundTransferData transferData = new FundTransferData();

    try {
      var response = await _dio
          .get("${_baseUrl}/v2/fundtransfer/detail?id=$fundTransferId");

      var data = response.data;
      var fundTransfer = FundTransferData.fromJson(data);
      if (fundTransfer != null) {
        transferData = fundTransfer;
      }
    } catch (e) {
      transferData.success = false;
      transferData.errorMessage = e.toString();
    }

    return transferData;
  }

  ///
  ///
  Future<TradingFee> getTradingFee(String instrument, String currency) async {
    TradingFee tradingFee = new TradingFee();

    try {
      var response = await _dio
          .get("${_baseUrl}/account/${instrument}/${currency}/tradingfee");

      var data = response.data;
      var fee = TradingFee.fromJson(data);
      if (fee != null) {
        tradingFee = fee;
      }
    } catch (e) {
      tradingFee.success = false;
      tradingFee.errorMessage = e.toString();
    }

    return tradingFee;
  }
}

enum SocketState {
  open,
  opening,
  close,
  closing,
  aborted,
}

class BtcMarketSocketsV2 {
  static final BtcMarketSocketsV2 _sockets = new BtcMarketSocketsV2._internal();

  factory BtcMarketSocketsV2() {
    return _sockets;
  }

  BtcMarketSocketsV2._internal() {
    _controller = StreamController.broadcast();
  }
  String _socketUrl = "wss://socket.btcmarkets.net/v2";

  String _key;
  String _secret;
  SocketState _socketState;
  SocketState get state => _socketState;

  IOWebSocketChannel _channel;
  IOWebSocketChannel get channel => _channel;

  StreamController _controller;
  StreamController get controller => _controller;

  void open() async {
    print('Opening');
    try {
      _channel = IOWebSocketChannel.connect(_socketUrl);

      if (_channel != null) {
       // print('Connected success');
        _socketState = SocketState.open;

        //print('Listening');
        _channel.stream.listen((message) {
          //print('received message $message');
          _controller.sink.add(message);
        }, onError: (error, StackTrace stackTrace) {
          //print('received error $error $stackTrace');
        }, onDone: () {
          _socketState = SocketState.close;

          //print('onDone received');
        });
      }
    } catch (e) {
      //print("An error occurred $e");
    }
  }

  void updateCredentials(String apiKey, String apiSecret)
  {
      _key = apiKey;
      _secret = apiSecret;
  }

  void joinChannels(List<String> markets) {
    
    var timestamp = DateTime.now().toUtc().millisecondsSinceEpoch;

    var msg = {
      "marketIds": ['BTC-AUD','ETH-BTC','LTC-BTC'],
      "channels": ['orderChange','fundChange'],
      "messageType": 'subscribe',
      "timestamp" : timestamp
    };

    if(_secret != null && _secret.isNotEmpty)
    {
       
        var buffer = new StringBuffer();
        buffer.writeln("/users/self/subscribe");
        buffer.write(timestamp);

        var signature = _getSignature(_secret, buffer.toString());
        
        if(signature != null && signature.isNotEmpty)
        {
          msg["key"] = _key;
          msg["signature"] = signature;
        }

    }

    print("Joining channels");
    var request = json.encode(msg);

    _channel.sink.add(request);
  }

  void close() async {
    try {
      if (_channel != null) {
      //  print("Closing ");
        _channel.sink.close();
        _socketState = SocketState.close;
      }

      // if (_controller != null) {
      //   print("Controller closing");
      //   _controller.close();
      // }

    } catch (e) {}
  }

  void dispose()
  {
     close();
  }

  String _getSignature(String secret, String message) {
    var key = base64.decode(secret);
    final keyParam = new KeyParameter(key);

    var data = utf8.encode(message);
    final mac = new Mac("SHA-512/HMAC");
    mac.init(keyParam);
    var bytes = mac.process(data);

    var signature = base64.encode(bytes);

    return signature;
  }

  
}


/*

received message {"orderId":3276517839,"marketId":"LTC-BTC","type":"Limit","side":"Bid","openVolume":"10000","status":"Cancelled","triggerStatus":"","timestamp":"2019-05-19T12:03:01.876Z","trades":[],"messageType":"orderChange"}
received a message from controller {"orderId":3276517839,"marketId":"LTC-BTC","type":"Limit","side":"Bid","openVolume":"10000","status":"Cancelled","triggerStatus":"","timestamp":"2019-05-19T12:03:01.876Z","trades":[],"messageType":"orderChange"}

received message {"marketId":"BTC-AUD","timestamp":"2019-05-19T12:01:10.376Z","bestBid":"11684.97","bestAsk":"11721.86","lastPrice":"11692.22","volume24h":"302.85351449","messageType":"tick"}

received a message from controller {"marketId":"BTC-AUD","timestamp":"2019-05-19T12:01:10.376Z","bestBid":"11684.97","bestAsk":"11721.86","lastPrice":"11692.22","volume24h":"302.85351449","messageType":"tick"}
received message {"marketId":"BTC-AUD","timestamp":"2019-05-19T12:01:11.525Z","bestBid":"11684.97","bestAsk":"11719.77","lastPrice":"11692.22","volume24h":"302.85351449","messageType":"tick"}

received message {"messageType":"heartbeat","channels":[{"name":"tick","marketIds":["BTC-AUD"]},{"name":"heartbeat"}]}
received a message from controller {"messageType":"heartbeat","channels":[{"name":"tick","marketIds":["BTC-AUD"]},{"name":"heartbeat"}]}
received message {"messageType":"heartbeat","channels":[{"name":"tick","marketIds":["BTC-AUD"]},{"name":"heartbeat"}]}
received a message from controller {"messageType":"heartbeat","channels":[{"name":"tick","marketIds":["BTC-AUD"]},{"name":"heartbeat"}]}
received a message from controller {"marketId":"BTC-AUD","timestamp":"2019-05-19T11:35:34.877Z","bids":[["11744.81","0.63721056"],["11741.87","0.6"],["11737.49","0.2"],["11700.03","0.2"],["11700.01","3.24"],["11700","0.05088439"],["11699","0.15"],["11687.02","0.39"],["11687","0.0075"],["11645.33","0.68190245"],["11645.33","0.68583976"],["11644.17","32.4"],["11641.17","3"],["11630","0.5085754"],["11567","0.10429672"],["11550","1.7276"],["11550","2.14625899"],["11540","0.96844822"],["11517.74","0.5"],["11517.73","16.2"],["11501","0.01"],["11450","1.4"],["11440.49","0.15"],["11407","0.10025422"],["11399","0.2"],["11399","0.20928518"],["11340","1.01702725"],["11310","0.00834573"],["11254.99","0.01762012"],["11220","0.05"],["11210","0.01040228"],["11200","0.13976887"],["11200","0.18538296"],["11197.06","0.12536377"],["11160.8","0.01943596"],["11080","0.1"],["11050","0.012"],["11020","0.07"],["11017.38","0.08109239"],["11001.99","0.045"],["11001","0.73148338"],["11000","0.5923475"],["11000","0.5"],["11000","0.075"],["11000","0.0057"],["11000","0.8493601"],["10945","0.00155"],["10900.5","2"],["10900","1"],["10900","2.40880455"]],"asks":[["11757.12","0.18264145"],["11766.95","0.2"],["11768.96","0.49"],["11798.81","1.073"],["11798.82","0.67944121"],["11799.98","0.2"],["11800","0.37732756"],["11807.97","3"],["11808.64","0.6"],["11838.82","0.67701879"],["11840","0.08492655"],["11842.05","3.24"],["11842.06","0.003999"],["11849","0.4551288"],["11850","1"],["11860","0.30311166"],["11899","1"],["11899","0.51761873"],["11899.99","32.4"],["11900","0.00121"],["11900","0.025"],["11925","0.1"],["11928","0.09561892"],["11941","0.14918762"],["11944.99","0.5"],["11945","0.1074435"],["11945","0.6498206"],["11946.58","0.1"],["11949","0.0835"],["11949.49","0.005"],["11949.95","0.25"],["11950","1"],["11952","0.5"],["11960","0.00640628"],["11964.99","0.452556"],["11965","0.47"],["11968.02","0.36619"],["11979","0.02"],["11980","1"],["11980","0.02584727"],["11980.68","0.03673083"],["11989","0.4"],["11990","0.00184231"],["11990","0.00990855"],["11994","0.15"],["11999","0.43478903"],["11999","0.1289007"],["11999.94","0.04"],["12000","0.01"],["12000","0.21348436"]],"messageType":"orderbook"}
*/