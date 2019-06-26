import 'dart:async';
import 'dart:convert';
import 'package:btcmarkets/helpers/cryptohelper.dart';
import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:btcmarkets/models/appmessage.dart';
import 'package:btcmarkets/models/markethistory.dart';
import 'package:btcmarkets/models/marketsgroup.dart';
import 'package:btcmarkets/models/markettrades.dart';
import 'package:btcmarkets/models/navview.dart';
import 'package:btcmarkets/models/newsitem.dart';
import 'package:btcmarkets/models/settings.dart';
import 'package:btcmarkets/models/walletcurrency.dart';
import 'package:btcmarkets/models/walletfundtransfer.dart';
import 'package:btcmarkets/models/walletorder.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

import '../api/btcmarketsapi.dart';
import '../constants.dart';
import '../models/marketdata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppDataModel {
  BtcMarketsApi _api;

  final ApiCredentials apiCredentials = new ApiCredentials();

  final List<MarketData> markets = new List<MarketData>();
  final List<MarketData> previousMarkets = new List<MarketData>();
  final List<ActiveMarket> activeMarkets = new List<ActiveMarket>();

  final List<WalletCurrency> balances = new List<WalletCurrency>();

  final Settings settings = new Settings();

  final MarketHistory marketHistory = new MarketHistory();

  MarketTrades _marketTrades = new MarketTrades();
  MarketTrades get marketTrades => _marketTrades;

  List<MarketData> get audMarkets =>
      markets.where((m) => m.currency == Constants.AUD).toList();

  List<MarketData> get btcMarkets =>
      markets.where((m) => m.currency == Constants.BTC).toList();

  List<MarketData> get favMarkets => markets.where((m) => m.isStarred).toList();

  final List<String> _favourites = new List<String>();
  List<String> get favourites => _favourites;

  final List<MarketsGroup> marketsGroups = new List<MarketsGroup>();

  bool isLoading = false;

  final StreamController<bool> _pageLoading =
      StreamController<bool>.broadcast();

  final StreamController<AppMessage> _messageNotifier =
      StreamController<AppMessage>.broadcast();

  final StreamController<String> _marketsRefreshController =
      StreamController<String>.broadcast();

  final StreamController<String> _marketHistoryController =
      StreamController<String>.broadcast();

  final StreamController<String> _tradesRefreshController =
      StreamController<String>.broadcast();

  final StreamController<String> _settingsController =
      StreamController<String>.broadcast();

  final StreamController<NavView> _navController =
      StreamController<NavView>.broadcast();

  StreamSink<String> get marketsRefreshSink => _marketsRefreshController.sink;
  Stream<String> get marketsRefreshStream => _marketsRefreshController.stream;

  StreamSink<String> get marketHistorySink => _marketHistoryController.sink;
  Stream<String> get marketHistoryStream => _marketHistoryController.stream;

  StreamSink<bool> get pageLoadingSink => _pageLoading.sink;
  Stream<bool> get pageLoadingStream => _pageLoading.stream;

  StreamSink<AppMessage> get messageNotifierSink => _messageNotifier.sink;
  Stream<AppMessage> get messageNotifierStream => _messageNotifier.stream;

  StreamSink<NavView> get navSink => _navController.sink;
  Stream<NavView> get navStream => _navController.stream;

  StreamSink<String> get tradesRefreshSink => _tradesRefreshController.sink;
  Stream<String> get tradesRefreshStream => _tradesRefreshController.stream;

  StreamSink<String> get settingsSink => _settingsController.sink;
  Stream<String> get settingsStream => _settingsController.stream;

  NavView view;

  AppDataModel() {
    _api = new BtcMarketsApi();

    var navView = NavView();
    navView.view = View.Home;
    navView.subView = SubView.None;
    view = navView;
    loadSettings();
  }

  bool get isValidAccount {
    return apiCredentials.isValid;
  }

  void switchView(NavView nav) {
    view = nav;
    navSink.add(nav);
  }

  void switchTheme(String theme) {
    settings.theme = theme;
    settingsSink.add("themeChanged");
  }

  void refreshApp() {
    settingsSink.add("");
  }

  bool get hasCredentialsChanged
  {
    var apiKey = apiCredentials.apiKey;
    var secret = apiCredentials.secret;

    //print("in has credetials $apiKey $secret ${_api.apiKey} ${_api.secret}, ${apiCredentials.isValid}");
   return (_api.apiKey == null || _api.secret == null) || (apiCredentials.isValid && (apiKey != _api.apiKey || secret != _api.secret));

  }
  Future saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var settingsData = json.encode(settings);
     // print("Settings data $settingsData");
      prefs.setString("settings", settingsData);
   //   showMessage("Saved settings successfully");
    } catch (e) {
      //showError("Something went wrong while saving settings");
    }
  }

  Future loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      settings.credentials = "";
      settings.theme = "Dark";
      settings.liveUpdates = true;
      settings.notifications = true;

      var settingsJson = prefs.getString("settings");

      //print("LOading settings $settingsJson");
      if (settingsJson != null && settingsJson.isNotEmpty) {
        var data = json.decode(settingsJson);
        //print("Settings data from json $data");
        if (data != null) {
          var credentials = data["credentials"];
          //print("Data not null ${credentials}");
          var theme = data["theme"];
          if (theme == null || theme.isEmpty) {
            theme = "Dark";
          }
          settings.credentials = data["credentials"];
          settings.theme = data["theme"];
          settings.liveUpdates = data["liveUpdates"];
          settings.notifications = data["notifications"];

         
        }
      }
    } catch (e) {
     // showError("Something went wrong while loading settings");
     print(e);
    }
     settingsSink.add("Refresh");
  }

  Future<bool> loadCredentials(String password) async {
    var success = false;
    var credentials = settings.credentials;
    //print("Settings credentisl ${settings.credentials}");
    if (credentials != null && credentials.isNotEmpty) {
      if (password == null || password.isEmpty) {
      //  showError("Password is required.");
        return false;
      }
      try {
        //print("Decrypting");
        var apiJson = CryptoHelper.decrypt(password, credentials);
        //print("decoding $apiJson");
        var obj = json.decode(apiJson);
        var apiKey = obj["apiKey"];
        var secret = obj["secret"];
        //print(apiKey);
        //print(secret);
        apiCredentials.apiKey = apiKey;
        apiCredentials.secret = secret;
        _api.updateCredentials(apiCredentials.apiKey, apiCredentials.secret);
        return true;
      } catch (cryptoError) {
        print(cryptoError);
        showError("Invalid password. Please provide a valid password.");
        return false;
      }
    }
    else
   
    return success;
  }

  ApiCredentials get currentCredentials => ApiCredentials(apiKey: _api.apiKey, secret: _api.secret);
 // bool passwordRequired = true;
  bool get passwordRequired =>
   settings.credentials != null && settings.credentials.isNotEmpty && !currentCredentials.isValid;

  void resetCredentails()
  {
    _api.updateCredentials("", "");
    settings.credentials = "";
    saveSettings();
  }

  Future<bool> updateCredentials(String password) async {
    var success = true;

    var apiKey = apiCredentials.apiKey;
    var secret = apiCredentials.secret;
    var valid = apiCredentials.isValid &&
        (_api.apiKey != apiKey || _api.secret != secret);

  //  print(
   //     "updateCred is valid $valid ${apiCredentials.isValid} ${_api.apiKey} ${_api.secret}");

    if (apiCredentials.isValid) {
      if (password == null || password.isEmpty) {
        //showError("Password is required.");

        return false;
      }
      //   apiCredentials.apiKey = apiKey;
      // apiCredentials.secret = secret;

      var data = json.encode(apiCredentials);
      var encrypted = CryptoHelper.encrypt(password, data);

      if (settings.credentials == null || settings.credentials.isEmpty) {
        settings.credentials = encrypted;
      }
     // print("Credentials enrcypted string ${settings.credentials}");

      if (_api.apiKey != apiKey || _api.secret != secret) {
        settings.credentials = encrypted;
        _api.updateCredentials(apiCredentials.apiKey, apiCredentials.secret);
        //print("updated credentials");
        refreshMarkets();
      }
    }
    return success;
  }

 
  Future refreshMarkets({isPullToRefesh = false}) async {
    debugPrint('Refreshing');

    if (!isPullToRefesh) {
      isLoading = true;
      pageLoadingSink.add(true);
    }

    try {
      if (activeMarkets.isEmpty) {
      //  print('getting active markets');
        var activeMarketResponse = await _api.getActiveMarkets();
        if (activeMarketResponse.success) {
          var activeMars = activeMarketResponse.activeMarkets;
          if (activeMars != null && activeMars.isNotEmpty) {
            for (var activeMarket in activeMars) {
              activeMarkets.add(activeMarket);
            }
          }
        } else {
          showError("Something went wrong while retrieving active markets");
          return;
        }
      }
      markets.clear();

      var data = await _api.getMarkets(activeMarkets: activeMarkets);

      if (isValidAccount) {
        try {
          await refreshBalances();
        } catch (e) {}
      }

      for (Market market in data.markets) {
        MarketData marketData = MarketData();
        marketData.currency = market.currency;
        marketData.instrument = market.instrument;
        marketData.volume24h = market.volume24h;
        marketData.lastPrice = market.lastPrice;

        marketData.bestAsk = market.bestAsk;
        marketData.bestBid = market.bestBid;
        marketData.timestamp = market.timestamp;
        marketData.isStarred = _favourites.any((m) => m == market.pair);
        marketData.holdings = 0.0;
        marketData.name =
            MarketHelper.getMarketName(market.instrument.toLowerCase());

        if (market.currency == Constants.BTC) {
          marketData.groupId = 3;
          marketData.group = Constants.BtcMarkets;
        } else if (market.currency == Constants.AUD) {
          marketData.groupId = 2;
          marketData.group = Constants.AudMarkets;
        } else if (marketData.isStarred) {
          marketData.groupId = 1;
          marketData.group = Constants.Favourites;
        }

        try {
          if (balances.isNotEmpty) {
            var balance = balances
                .firstWhere((bal) => bal.currency == marketData.instrument);
            if (balance != null) {
              //sprint("Balance found ${balance.currency}");
              marketData.holdings = balance.pending + balance.balance;
            }
          }
        } catch (e) {
          print(e);
        }

        try {
          if (marketData.currency == Constants.AUD) {
            var history = await getMarketHistory(marketData, "1D", limit: 1);
            if (history.data.isNotEmpty) {
              var tick = history.data[0];
              //  print(tick);
              marketData.prevPrice = tick["open"];
              //   print("${marketData.pair}, ${marketData.lastPrice},${marketData.prevPrice},${marketData.change},${marketData.changeString}");
              //   print(marketData.changeString);
            }
          }
        } catch (e) {
          print(e);
        }
        markets.add(marketData);
      }
    } catch (e) {
      showError(null);
    }

    marketsRefreshSink.add("Refresh");

    // markets.sort((a,b)=> a.groupId.compareTo(b.groupId));

    if (!isPullToRefesh) {
      isLoading = false;
      pageLoadingSink.add(false);
    }
  }

  Future<String> getTotalBalanceString(bool inBtc) async {
    var currency = inBtc ? Constants.BTC : Constants.AUD;

    var balance = await getTotalBalance(inBtc);

    var balString = MarketHelper.getValueFormat(currency, balance);

    return balString;
  }

  Future<double> getTotalBalance(bool inBtc) async {
    double total = 0.0;
    try {
      if (markets.isEmpty) {
        await refreshMarkets();
      }

      var audBalance =
          balances.firstWhere((bal) => bal.currency == Constants.AUD);
      var btcMarket = markets.firstWhere((market) =>
          market.currency == Constants.AUD &&
          market.instrument == Constants.BTC);
      var audTotal = 0.0;
      markets.forEach((m) {
        if (m.currency == Constants.AUD) {
          if (m.holdings > 0 && m.lastPrice > 0) {
            audTotal += m.lastPrice * m.holdings;
          }
        }
      });

      audTotal += audBalance.total;

      if (inBtc) {
        if (btcMarket.lastPrice > 0) {
          total = audTotal / btcMarket.lastPrice;
        }
      } else {
        total = audTotal;
      }
    } catch (e) {}
    return total;
  }

  Future<MarketTrades> getTrades(String instrument, String currency) async {
    await refreshTrades(instrument, currency);
    return _marketTrades;
  }

  Future<bool> checkAuthentication(String apiKey, String secret) async {
    var isValid = false;

    try {
      print("checking authentication");
      //var api = BtcMarketsApi();
      var credentials = currentCredentials;

      _api.updateCredentials(apiKey, secret);
      

      var response = await _api.getAccountBalances();
      _api.updateCredentials(credentials.apiKey, credentials.secret);
      
      if (response.success) {
        print("response valid");
        isValid = true;
      } else {
        print(response.errorMessage);
        //showError(response.errorMessage);
      }
    } catch (e) {
      print(e);
      //showError(null);
    }

    return isValid;
  }
  
  Future refreshBalances() async {
    try {
      var accountData = await _api.getAccountBalances();

      if (accountData.success) {
        balances.clear();
        var walletBal = accountData.balances;

        if (walletBal != null && walletBal.isNotEmpty) {
          var audBal = walletBal.firstWhere((b) => b.currency == Constants.AUD);

          var audName = MarketHelper.getMarketName(Constants.AUD.toLowerCase());
          if (audBal != null) {
            balances.add(WalletCurrency(
                name: audName,
                currency: audBal.currency,
                balance: audBal.balanceValue,
                pending: audBal.pendingFundsValue));
          } else {
            balances.add(WalletCurrency(
                currency: Constants.AUD, balance: 0.0, pending: 0.0));
          }
          var btcBal = walletBal.firstWhere((b) => b.currency == Constants.BTC);
          var btcName = MarketHelper.getMarketName(Constants.BTC.toLowerCase());
          if (btcBal != null) {
            balances.add(WalletCurrency(
                name: btcName,
                currency: btcBal.currency,
                balance: btcBal.balanceValue,
                pending: btcBal.pendingFundsValue));
          } else {
            balances.add(WalletCurrency(
                currency: Constants.BTC, balance: 0.0, pending: 0.0));
          }
          walletBal.sort((a, b) => a.currency.compareTo(b.currency));

          walletBal.forEach((bal) {
            var isMarketExist =
                activeMarkets.any((m) => m.instrument == bal.currency);

            if (bal.currency != Constants.AUD &&
                bal.currency != Constants.BTC &&
                isMarketExist) {
              var walletBal = WalletCurrency(
                  name: MarketHelper.getMarketName(bal.currency.toLowerCase()),
                  currency: bal.currency,
                  balance: bal.balanceValue,
                  pending: bal.pendingFundsValue);

              balances.add(walletBal);
            }
          });
        }
      } else {
        showError(accountData.errorMessage);
      }
    } catch (e) {
      showError(null);
    }
  }

  Future<List<WalletCurrency>> getWalletBalances({bool hideZeroBalance}) async {
    var walletBalances = new List<WalletCurrency>();

    await refreshBalances();

    balances.forEach((walletBal) {
      if (!hideZeroBalance ||
          (hideZeroBalance &&
              (walletBal.balance > 0 || walletBal.pending > 0))) {
        walletBalances.add(walletBal);
      }
    });

    return walletBalances;
  }

  Future<List<WalletOrder>> getOpenOrders() async {
    var openOrders = new List<WalletOrder>();

    try {
      var response = await _api.getOpenOrders();

      if (response.success) {
        var orders = response.orders;
        orders.forEach((order) {
          var walletOrder = new WalletOrder();
          walletOrder.id = order.id;
          walletOrder.instrument = order.instrument;
          walletOrder.currency = order.currency;
          walletOrder.price = order.priceValue;
          walletOrder.volume = order.volumeValue;
          walletOrder.side = order.orderSide;
          walletOrder.type = order.ordertype;
          walletOrder.timestamp = order.creationTime;
          walletOrder.status = order.status;
          openOrders.add(walletOrder);
        });
      } else {
        showError(response.errorMessage);
      }
    } catch (e) {
      showError(null);
    }

    return openOrders;
  }

  Future<List<WalletOrder>> getOrderHistory(MarketData market) async {
    if (market == null) {
      market = markets[0];
    }
    var openOrders = new List<WalletOrder>();

    try {
      var response =
          await _api.getOrderHistory(market.instrument, market.currency);

      if (response.success) {
        var orders = response.orders;

        orders.forEach((order) {
          var walletOrder = new WalletOrder();

          walletOrder.id = order.id;
          walletOrder.instrument = order.instrument;
          walletOrder.currency = order.currency;
          walletOrder.price = order.priceValue;
          walletOrder.volume = order.volumeValue;
          walletOrder.side = order.orderSide;
          walletOrder.type = order.ordertype;
          walletOrder.timestamp = order.creationTime;
          walletOrder.status = order.status;

          if (order.trades != null) {
            var trades = new List<WalletTrade>();

            order.trades.forEach((trade) {
              var t = WalletTrade();
              t.timestamp = trade.creationTime;
              t.price = trade.priceValue;
              t.volume = trade.volumeValue;
              trades.add(t);
            });

            walletOrder.trades = trades;
          }
          openOrders.add(walletOrder);
        });
      } else {
        showError(response.errorMessage);
      }
    } catch (e) {
      showError(null);
    }

    return openOrders;
  }

  Future<List<WalletFundTransfer>> getFundsHistory() async {
    var fundTransfers = new List<WalletFundTransfer>();
    try {
      var response = await _api.getFundTransferHistory();
      if (response.success) {
        var transfers = response.fundTransfers;
        transfers.forEach((transfer) {
          var fundTransfer = new WalletFundTransfer();
          fundTransfer.id = transfer.fundTransferId;

          fundTransfer.currency = transfer.currency;
          fundTransfer.amount = transfer.amountValue;
          fundTransfer.fee = transfer.feeValue;
          fundTransfer.description = transfer.description;
          fundTransfer.transferType = transfer.transferType;

          if (transfer.cryptoPaymentDetail != null) {
            fundTransfer.txid = transfer.cryptoPaymentDetail["txid"];
            fundTransfer.address = transfer.cryptoPaymentDetail["address"];
          }
          fundTransfer.lastUpdate = transfer.lastUpdate;
          fundTransfer.timestamp = transfer.creationTime;
          fundTransfer.status = transfer.status;
          fundTransfers.add(fundTransfer);
        });
      } else {
        showError(response.errorMessage);
      }
    } catch (e) {
      showError(null);
    }

    return fundTransfers;
  }

  Future refreshTrades(String instrument, String currency,
      {isPullToRefesh = false}) async {
    try {
      var data = await _api.getOrderBook(instrument, currency);
      if (data.success) {
        _marketTrades = MarketTrades.fromBook(data);
      } else {
        showError(data.errorMessage);
      }
    } catch (e) {
      showError(null);

      _marketTrades = new MarketTrades();
    }

    tradesRefreshSink.add("Refresh");
  }

  void showError(String error) {
    if (error == null) {
      error = "Something went wrong.";
    }

    var err = AppMessage();
    err.messageType = MessageType.error;
    err.message = error;
    messageNotifierSink.add(err);
  }

  void showMessage(String message) {
    if (message != null && message.isNotEmpty) {
      var mess = new AppMessage();
      mess.messageType = MessageType.success;
      mess.message = message;
      messageNotifierSink.add(mess);
    }
  }

  Future<MarketHistory> getMarketHistory(MarketData market, String duration,
      {int limit}) async {
    // pageLoadingSink.add(true);

    marketHistory.duration = duration;
    marketHistory.market = market;

    try {
      TickTime tickTime;
      DateTime dateTime;

      switch (duration) {
        case "1H":
          dateTime = DateTime.now().subtract(new Duration(hours: 1));
          tickTime = TickTime.minute;
          break;
        case "6H":
          dateTime = DateTime.now().subtract(new Duration(hours: 6));
          tickTime = TickTime.hour;
          break;
        case "12H":
          dateTime = DateTime.now().subtract(new Duration(hours: 12));
          tickTime = TickTime.hour;
          break;
        case "1D":
          dateTime = DateTime.now().subtract(new Duration(days: 1));
          tickTime = TickTime.hour;
          break;
        case "3D":
          dateTime = DateTime.now().subtract(new Duration(days: 3));
          tickTime = TickTime.day;
          break;
        case "1W":
          dateTime = DateTime.now().subtract(new Duration(days: 7));
          tickTime = TickTime.day;
          break;
        case "2W":
          dateTime = DateTime.now().subtract(new Duration(days: 14));
          tickTime = TickTime.day;
          break;
        case "1M":
          dateTime = DateTime.now().subtract(new Duration(days: 30));
          tickTime = TickTime.day;
          break;
        case "3M":
          dateTime = DateTime.now().subtract(new Duration(days: 90));
          tickTime = TickTime.day;
          break;
        case "6M":
          dateTime = DateTime.now().subtract(new Duration(days: 180));
          tickTime = TickTime.day;
          break;
        case "1Y":
          dateTime = DateTime.now().subtract(new Duration(days: 365));
          tickTime = TickTime.day;
          break;
        case "ALL":
          dateTime = DateTime.now().subtract(new Duration(days: (365 * 3)));
          tickTime = TickTime.day;
          break;
        default:
          dateTime = DateTime.now().subtract(new Duration(days: 1));
          break;
      }

      var history = await _api.getHistoricalTicks(
          market.instrument, market.currency, tickTime, dateTime, true,
          limit: limit);
      if (history.success) {
        var ticks = history.ticks;
        marketHistory.refresh(ticks);
      } else {
        // print(history.errorMessage);

        marketHistory.refresh([]);
      }
    } catch (e) {
      print("Exception in marketHistory **************");
      print(e);
    }

    //  pageLoadingSink.add(false);
    return marketHistory;
  }

  Future refreshMarketHistory(MarketData market, String duration) async {
    // pageLoadingSink.add(true);
    marketHistorySink.add(null);
    marketHistory.duration = duration;
    marketHistory.market = market;
    try {
      TickTime tickTime;
      DateTime dateTime;

      switch (duration) {
        case "1H":
          dateTime = DateTime.now().subtract(new Duration(hours: 1));
          tickTime = TickTime.minute;
          break;
        case "3H":
          dateTime = DateTime.now().subtract(new Duration(hours: 3));
          tickTime = TickTime.hour;
          break;
        case "6H":
          dateTime = DateTime.now().subtract(new Duration(hours: 6));
          tickTime = TickTime.hour;
          break;
        case "12H":
          dateTime = DateTime.now().subtract(new Duration(hours: 12));
          tickTime = TickTime.hour;
          break;
        case "1D":
          dateTime = DateTime.now().subtract(new Duration(days: 1));
          tickTime = TickTime.hour;
          break;
        case "3D":
          dateTime = DateTime.now().subtract(new Duration(days: 3));
          tickTime = TickTime.day;
          break;
        case "1W":
          dateTime = DateTime.now().subtract(new Duration(days: 7));
          tickTime = TickTime.day;
          break;
        case "2W":
          dateTime = DateTime.now().subtract(new Duration(days: 14));
          tickTime = TickTime.day;
          break;
        case "1M":
          dateTime = DateTime.now().subtract(new Duration(days: 30));
          tickTime = TickTime.day;
          break;
        case "3M":
          dateTime = DateTime.now().subtract(new Duration(days: 90));
          tickTime = TickTime.day;
          break;
        case "6M":
          dateTime = DateTime.now().subtract(new Duration(days: 180));
          tickTime = TickTime.day;
          break;
        case "1Y":
          dateTime = DateTime.now().subtract(new Duration(days: 365));
          tickTime = TickTime.day;
          break;
        case "ALL":
          dateTime = DateTime.now().subtract(new Duration(days: (365 * 3)));
          tickTime = TickTime.day;
          break;
        default:
          dateTime = DateTime.now().subtract(new Duration(days: 1));
          break;
      }

      var history = await _api.getHistoricalTicks(
          market.instrument, market.currency, tickTime, dateTime, true);
      if (history.success) {
        var ticks = history.ticks;
        marketHistory.refresh(ticks);
      }
    } catch (e) {
      print("Exception in marketHistory **************");
      print(e);
    }

    marketHistorySink.add("refresh");
    //  pageLoadingSink.add(false);
  }

  void updateFavourite(MarketData market, bool add) {
    bool refresh = false;

    market.isStarred = add;
    refresh = true;
    if (add) {
      var isAdded = _favourites.any((m) => m == market.pair);
      if (!isAdded) {
        _favourites.add(market.pair);

        refresh = true;
      }
    } else {
      var favMarket = _favourites.any((m) => m == market.pair);

      if (favMarket != null) {
        _favourites.removeWhere((m) => m == market.pair);

        refresh = true;
      }
    }

    // var favGroup = marketsGroups.firstWhere((group) => group.groupName == Constants.Favourites);
    // if(favGroup != null)
    // {
    //  MarketsGroup curGroup;
    //     if(market.currency == Constants.BTC)
    //     {
    //       curGroup = marketsGroups.firstWhere((group) => group.groupName == Constants.BtcMarkets);
    //     }
    //     else
    //     if(market.currency == Constants.AUD)
    //     {
    //       curGroup = marketsGroups.firstWhere((group) => group.groupName == Constants.AudMarkets);
    //     }

    //     if(curGroup != null)
    //     {
    //        var curMarket = curGroup.markets.firstWhere((m)=>m.pair == market.pair);
    //        if(curMarket != null)
    //        {
    //          curMarket.isStarred = add;
    //          refresh = true;
    //        }
    //     }

    //   if(add)
    //   {
    //     market.isStarred = add;
    //     favMarkets.add(market);

    //     refresh = true;
    //    // favGroup.markets.add(market);
    //   }
    //   else
    //   {
    //     var favMarket = favMarkets.firstWhere((m)=> m.pair == market.pair);
    //     if(favMarket != null)
    //     {
    //       favMarket.isStarred = add;
    //       favMarkets.removeWhere((m)=> m.pair == market.pair);
    //       refresh = true;
    //     }
    //   }
    // }

    if (refresh) {
      marketsRefreshSink.add("Refresh");
    }
  }

  List<NewsItem> _newsItems;
  Future<List<NewsItem>> getNews() async {
    if (_newsItems == null || _newsItems.length <= 0) {
      if (_newsItems == null) {
        _newsItems = new List<NewsItem>();
      }

      try {
        var dio = new Dio();
        var response = await dio.get(
            "https://support.btcmarkets.net/hc/en-us/categories/360000148368-News-and-Announcements");
        var html = response.data;

        var document = parse(html);

        var links = document.querySelectorAll('a.article-list-link');

        for (var link in links) {
          var newsItem = new NewsItem();
          newsItem.title = link.text;
          newsItem.link =
              "https://support.btcmarkets.net" + link.attributes["href"];
          _newsItems.add(newsItem);
        }
      } catch (e) {}
    }
    return _newsItems;
  }

  void dispose() {
    _marketsRefreshController.close();
    _marketHistoryController.close();
    _tradesRefreshController.close();
    _settingsController.close();
    _navController.close();
    _pageLoading.close();
    _messageNotifier.close();
  }
}
