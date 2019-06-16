import 'dart:async';
import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:btcmarkets/models/markethistory.dart';
import 'package:btcmarkets/models/marketsgroup.dart';
import 'package:btcmarkets/models/newsitem.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

import '../api/btcmarketsapi.dart';
import '../constants.dart';
import '../models/marketdata.dart';

class AppDataModel{
  BtcMarketsApi _api;

  final List<MarketData> markets = new List<MarketData>();

  final List<MarketHistory> marketHistory = new List<MarketHistory>();

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

  final StreamController<String> _marketsRefreshController =
      StreamController<String>.broadcast();

  final StreamController<String> _marketHistoryController =
      StreamController<String>.broadcast();

  StreamSink<String> get marketsRefreshSink => _marketsRefreshController.sink;
  Stream<String> get marketsRefreshStream => _marketsRefreshController.stream;

  StreamSink<String> get marketHistorySink => _marketHistoryController.sink;
  Stream<String> get marketHistoryStream => _marketHistoryController.stream;

  StreamSink<bool> get pageLoadingSink => _pageLoading.sink;
  Stream<bool> get pageLoadingStream => _pageLoading.stream;

  AppDataModel() {
    _api = new BtcMarketsApi();
  }

  Future refreshMarkets({isPullToRefesh = false}) async {
    debugPrint('Refreshing');

    if (!isPullToRefesh) {
      isLoading = true;
      pageLoadingSink.add(true);
    }

    try {
      var data = await _api.getMarkets();

      markets.clear();

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

        markets.add(marketData);
      }
    } catch (e) {}

    marketsRefreshSink.add("Refresh");

    // markets.sort((a,b)=> a.groupId.compareTo(b.groupId));

    if (!isPullToRefesh) {
      isLoading = false;
      pageLoadingSink.add(false);
    }
  }

  Future<List<MarketHistory>> getMarketHistory(
      MarketData market, String duration) async {
   // pageLoadingSink.add(true);
    marketHistory.clear();

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
          tickTime = TickTime.minute;
          break;
        case "12H":
          dateTime = DateTime.now().subtract(new Duration(hours: 12));
          tickTime = TickTime.minute;
          break;
        case "1D":
          dateTime = DateTime.now().subtract(new Duration(days: 1));
          tickTime = TickTime.hour;
          break;
        case "3D":
          dateTime = DateTime.now().subtract(new Duration(days: 3));
          tickTime = TickTime.hour;
          break;
        case "1W":
          dateTime = DateTime.now().subtract(new Duration(days: 7));
          tickTime = TickTime.hour;
          break;
        case "2W":
          dateTime = DateTime.now().subtract(new Duration(days: 14));
          tickTime = TickTime.hour;
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
        for (var tick in ticks) {
          var markHistory = new MarketHistory();
          markHistory.high = tick.highValue;
          markHistory.low = tick.lowValue;
          markHistory.open = tick.openValue;
          markHistory.close = tick.closeValue;
          markHistory.volumeto = tick.volumeValue;

          marketHistory.add(markHistory);
        }
      }
    } catch (e) {
      print("Exception in marketHistory **************");
      print(e);
    }

  //  pageLoadingSink.add(false);
    return marketHistory;
  }

  Future refreshMarketHistory(MarketData market, String duration) async {
    pageLoadingSink.add(true);
    marketHistory.clear();
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
          tickTime = TickTime.minute;
          break;
        case "12H":
          dateTime = DateTime.now().subtract(new Duration(hours: 12));
          tickTime = TickTime.minute;
          break;
        case "1D":
          dateTime = DateTime.now().subtract(new Duration(days: 1));
          tickTime = TickTime.hour;
          break;
        case "3D":
          dateTime = DateTime.now().subtract(new Duration(days: 3));
          tickTime = TickTime.hour;
          break;
        case "1W":
          dateTime = DateTime.now().subtract(new Duration(days: 7));
          tickTime = TickTime.hour;
          break;
        case "2W":
          dateTime = DateTime.now().subtract(new Duration(days: 14));
          tickTime = TickTime.hour;
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
       // ticks.sort((a, b) => a.dateTime.compareTo(b.dateTime));
        for (var tick in ticks) {
          var markHistory = new MarketHistory();
          markHistory.high = tick.highValue;
          markHistory.low = tick.lowValue;
          markHistory.open = tick.openValue;
          markHistory.close = tick.closeValue;
          markHistory.volumeto = tick.volumeValue;

          marketHistory.add(markHistory);
        }
      }
    } catch (e) {
      print("Exception in marketHistory **************");
      print(e);
    }

    marketHistorySink.add("refresh");
    pageLoadingSink.add(false);
  }

  void updateFavourite(MarketData market, bool add) {
    bool refresh = false;
    debugPrint("Updating favourite ${market.pair} -> $add");

    debugPrint("FavGroup found");
    market.isStarred = add;
    refresh = true;
    if (add) {
      debugPrint("Adding new");

      var isAdded = _favourites.any((m) => m == market.pair);
      debugPrint("Isadded $isAdded");
      if (!isAdded) {
        debugPrint("Adding found");
        _favourites.add(market.pair);

        refresh = true;
      }
    } else {
      debugPrint("Removing");
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
  Future<List<NewsItem>> GetNews() async {
    if (_newsItems == null || _newsItems.length<=0) {
        
      if(_newsItems == null)
      {
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
          newsItem.link = link.attributes["href"];
          _newsItems.add(newsItem);

        }
      } catch (e) {
       
      }
    }
    return _newsItems;
  }

  void dispose() {
    _marketsRefreshController.close();
    _marketHistoryController.close();
    _pageLoading.close();
  }

  
}
