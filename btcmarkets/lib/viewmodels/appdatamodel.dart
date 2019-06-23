import 'dart:async';
import 'package:btcmarkets/helpers/markethelper.dart';
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

class AppDataModel {
  BtcMarketsApi _api;

  final List<MarketData> markets = new List<MarketData>();
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

  final StreamController<String> _errorNotifier =
      StreamController<String>.broadcast();

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

  StreamSink<String> get errorNotifierSink => _errorNotifier.sink;
  Stream<String> get errorNotifierStream => _errorNotifier.stream;

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

    settings.apiKey = "";
    settings.secret = "";
    _api.updateCredentials(settings.apiKey, settings.secret);
  }

  bool get isValidAccount {
    return settings.apiKey != null &&
        settings.apiKey.isNotEmpty &&
        settings.secret != null &&
        settings.secret.isNotEmpty;
  }

  void switchView(NavView nav) {
    view = nav;
    navSink.add(nav);
  }

  void switchTheme(String theme) {
    settings.theme = theme;
    settingsSink.add("themeChanged");
  }

  Future refreshMarkets({isPullToRefesh = false}) async {
    debugPrint('Refreshing');

    if (!isPullToRefesh) {
      isLoading = true;
      pageLoadingSink.add(true);
    }

    try {
      if (activeMarkets.isEmpty) {
        var activeMarketResponse = await _api.getActiveMarkets();
        if (activeMarketResponse.success) {
          var activeMars = activeMarketResponse.activeMarkets;
          if (activeMars != null && activeMars.isNotEmpty) {
            for (var activeMarket in activeMars) {
              activeMarkets.add(activeMarket);
            }
          }
        }
      }
        markets.clear();

        
      var data = await _api.getMarkets(activeMarkets: activeMarkets);
  
      try {
        await refreshBalances();
      } catch (e) {

        
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
        } catch (e) {}
        markets.add(marketData);
      }
    } catch (e) {

      _showError(null);
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
        _showError(accountData.errorMessage);
      }
    } catch (e) {
      _showError(null);
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
        _showError(response.errorMessage);
      }
    } catch (e) {
      _showError(null);
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
        _showError(response.errorMessage);
      }
    } catch (e) {
      _showError(null);
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
        _showError(response.errorMessage);
      }
    } catch (e) {
      _showError(null);
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
        _showError(data.errorMessage);
      }
    } catch (e) {
      _showError(null);

      _marketTrades = new MarketTrades();
    }

    tradesRefreshSink.add("Refresh");
  }

  void _showError(String error) {
    if (error == null || error.indexOf("Authentication") < 0) {
      error = "Something went wrong.";
    }

    errorNotifierSink.add(error);
  }

  Future<MarketHistory> getMarketHistory(
      MarketData market, String duration) async {
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
          market.instrument, market.currency, tickTime, dateTime, true);
      if (history.success) {
        var ticks = history.ticks;
        marketHistory.refresh(ticks);
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
    _errorNotifier.close();
  }
}
