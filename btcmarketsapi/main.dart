import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../btcmarkets/lib/api/btcmarketsapi.dart';
import '../btcmarkets/lib/constants.dart';
import 'tests.dart';
import 'package:intl/intl.dart';
class AppData {
  static final AppData _appData = new AppData._internal();

  factory AppData() {
    return _appData;
  }

  AppData._internal() {
    _api = new BtcMarketsApi();
  }

  BtcMarketsApi _api;
  BtcMarketsApi get api => _api;

  List<ActiveMarket> _activeMarkets;

  List<ActiveMarket> get activeMarkets => _activeMarkets;

  List<Market> _markets;

  List<Market> get markets => _markets;

  void refreshActiveMarkets() async {}

  void refreshMarkets() async {
    _markets = await getMarkets();
  }

void getOrderBook(String instrument, String currency) async
  {
    try{

      var data = await _api.getOrderBook(instrument, currency);

      print(data.toJson());
    }
    catch(e)
    {
      print(e);
    }
  }
  void getHistoricalTicks() async
  {
    try{

      var since = DateTime.now().subtract(new Duration(days: 1));
      var data = await _api.getHistoricalTicks("LTC", "BTC", TickTime.hour, since, true);
      var ticks = data.ticks;
      print(ticks.length);
      ticks.sort((a,b)=>a.timeStamp.compareTo(b.timeStamp));

      for(var index=0;index<ticks.length;index++)
      {
        var tick = ticks[index];
       // print(DateTime.fromMillisecondsSinceEpoch(tick.timeStamp));
        print(tick.toJson());
      }

    }
    catch(e)
    {
      print(e);
    }
  }
  Future<List<Market>> getMarkets() async {
    List<Market> markets = new List<Market>();

    try {
      if (_activeMarkets == null || _activeMarkets.length == 0) {}

      for (var activeMarket in _activeMarkets) {
        var tick =
            await _api.getTick(activeMarket.instrument, activeMarket.currency);

        markets.add(Market.fromTick(tick));
      }
    } catch (e) {
      print(e);
    }

    return markets;
  }

  void updateCredentials(apiKey, secret) {
    _api.updateCredentials(apiKey, secret);
  }
}

void main() async {

//   print("adddd");
//   var password = "Oakton123";
//   var data = ;
//   testEncDec(password,data);

//   print("****************************************");

//   var encStr = encrypt(password, data);
//   print("Encrypted string ************* $encStr");

// print("****************************************");
  
//   var decStr = decrypt(password, encStr);
  
//   print("Decrypted string $decStr");
//  print("****************************************");
   
//var activeMarkets = await api.getActiveMarkets();

//for(var activeMarket in activeMarkets)

//{

//print(jsonEncode(activeMarket));

//}

//var market = await api.getTick("BTC","AUD");

//print(jsonEncode(market));
  // print("Retrieving markets from ");

  var appData = new AppData();

  var apiKey = "";
  var secret = "";
  
  appData.updateCredentials(apiKey, secret);

  //appData.getOrderBook("BTC","AUD");

  var balances = await appData.api.getAccountBalances();
  print(json.encode(balances));

  // var orderHistory = await appData.api.getOrderHistory("BTC", "AUD");
  // print(json.encode(orderHistory));

//     var tradeHistory = await appData.api.getTradeHistory("BTC", "AUD");
// print(json.encode(tradeHistory));

//  var openOrders = await appData.api.getOpenOrders();
// print(json.encode(openOrders));


//  var fundHistory = await appData.api.getFundTransferHistory();
// print(json.encode(fundHistory));

// var fundTransfer = await appData.api.getFundTransfer(2538214272);
// print(json.encode(fundTransfer));

// var withdrawalFee = await appData.api.getWithdrawalFee("BTC");
// print(json.encode(withdrawalFee));

// var depositAddress = await appData.api.getDepositAddress("BTC");
// print(json.encode(depositAddress));

  // var activeMarkets = await appData.api.getActiveMarkets();
  // print(json.encode(activeMarkets));
  // var tradingFee = await appData.api.getTradingFee("BTC", "AUD");
  // print(json.encode(tradingFee));

  // Stopwatch stopwatch = new Stopwatch()..start();
  // print('starting execution');
  // var markets = await appData.api.getMarkets();
  // print(json.encode(markets));
  // print('executed in ${stopwatch.elapsed}');

  //var markets = await appData.getMarkets();
  //  print(jsonEncode(markets));

  //testSignature();
  // testSockets();

  // var msg = {
  //     "marketIds": ['BTC-AUD'],
  //     "channels": ['tick', 'heartbeat'],
  //     "messageType": 'subscribe'
  //   };

  //   msg["key"] = "Key1";
  //   msg["secret"] = "Secret";

  //   print(json.encode(msg));
  //testSockets();
}
void testSockets() {

  var apiKey = "";
  var apiSecret =
      "";

  BtcMarketSocketsV2 socket = new BtcMarketSocketsV2();

  socket.updateCredentials(apiKey, apiSecret);

  ProcessSignal.sigint.watch().listen((ProcessSignal signal) {
    print("exiting");
    if (socket.state == SocketState.open) {
      socket.close();
    }
    print('Socket State ${socket.state}');

    exit(0);
  });

  socket.controller.stream.listen((message) {
    print('received a message from controller ${message}');
  }, onError: (error, StackTrace stackTrace) {
    print('Error received from controller ${error} ${stackTrace}');
  }, onDone: () {
    print("controller is closed");
  });

  print('opening sockets');
  socket.open();
  print('Socket State ${socket.state}');
  if (socket.state == SocketState.open) {
    print('socket opened');

    socket.joinChannels([]);
  }
}
