import 'dart:async';
import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:btcmarkets/models/marketsgroup.dart';
import 'package:flutter/foundation.dart';

import '../api/btcmarketsapi.dart';
import '../models/marketdata.dart';

class Constants {
  static const String BTC = "BTC";
  static const String AUD = "AUD";
}

class AppDataModel {
  BtcMarketsApi _api;

  final List<MarketData> markets = new List<MarketData>();
  final List<MarketData> audMarkets = new List<MarketData>();
  final List<MarketData> btcMarkets = new List<MarketData>();
  final List<MarketData> favMarkets = new List<MarketData>();

  final List<MarketsGroup> marketsGroups = new List<MarketsGroup>();

  bool isLoading = false;


  final StreamController<bool> _pageLoading =
      StreamController<bool>.broadcast();

  final StreamController<String> _marketsRefreshController =
      StreamController<String>.broadcast();

  final StreamController<String> _audMarketsRefreshController =
      StreamController<String>.broadcast();

  final StreamController<String> _btcMarketsRefreshController =
      StreamController<String>.broadcast();

 final StreamController<String> _favMarketsRefreshController =
      StreamController<String>.broadcast();


  StreamSink<String> get marketsRefreshSink => _marketsRefreshController.sink;
  Stream<String> get marketsRefreshStream => _marketsRefreshController.stream;

StreamSink<String> get audMarketsRefreshSink => _audMarketsRefreshController.sink;
  Stream<String> get audMarketsRefreshStream => _audMarketsRefreshController.stream;

StreamSink<String> get btcMarketsRefreshSink => _btcMarketsRefreshController.sink;
  Stream<String> get btcMarketsRefreshStream => _btcMarketsRefreshController.stream;

StreamSink<String> get favMarketsRefreshSink => _favMarketsRefreshController.sink;
  Stream<String> get favMarketsRefreshStream => _favMarketsRefreshController.stream;

  
  StreamSink<bool> get pageLoadingSink => _pageLoading.sink;
  Stream<bool> get pageLoadingStream => _pageLoading.stream;

  AppDataModel() {
    _api = new BtcMarketsApi();
  }

  Future refreshMarkets() async {
    debugPrint('Refreshing');

    isLoading = true;  
    pageLoadingSink.add(true);
   

    var data = await _api.getMarkets();

    marketsGroups.clear();
    markets.clear();
    btcMarkets.clear();
    audMarkets.clear();
    
    for (Market market in data.markets) {
      MarketData marketData = MarketData();
      marketData.currency = market.currency;
      marketData.instrument = market.instrument;
      marketData.volume24h = market.volume24h;
      marketData.lastPrice = market.lastPrice;

      marketData.bestAsk = market.bestAsk;
      marketData.bestBid = market.bestBid;
      marketData.timestamp = market.timestamp;
      marketData.isStarred = favMarkets.any((m) =>
          m.instrument == market.instrument &&
          m.currency == market.currency &&
          m.isStarred);

      marketData.name = MarketHelper.getMarketName(market.instrument.toLowerCase());
      
      if (market.currency == Constants.BTC) {
        marketData.groupId = 3;
        marketData.group = "BTC Markets";
      } else if (market.currency == Constants.AUD) {
        marketData.groupId = 2;
        marketData.group = "AUD Markets";
      } else if (marketData.isStarred) {
        marketData.groupId = 1;
        marketData.group = "Favourites";
      }

      if (market.currency == Constants.AUD) {
        audMarkets.add(marketData);
      } else if (market.currency == Constants.BTC) {
        btcMarkets.add(marketData);
      }

      markets.add(marketData);

    }

    var favGroup = new MarketsGroup();
    favGroup.groupId = 1;
    favGroup.groupName = "Favourites";
    favGroup.markets = favMarkets;

    var audGroup = new MarketsGroup();
    audGroup.groupId = 2;
    audGroup.groupName = "AUD Markets";
    audGroup.markets = audMarkets;
    
    var btcGroup = new MarketsGroup();
    btcGroup.groupId = 3;
    btcGroup.groupName = "BTC Markets";
    btcGroup.markets = btcMarkets;
    
    marketsGroups.add(favGroup);
    marketsGroups.add(audGroup);
    marketsGroups.add(btcGroup);

    // markets.sort((a,b)=> a.groupId.compareTo(b.groupId));
    isLoading = false;
    marketsRefreshSink.add("Refresh");
    pageLoadingSink.add(false);

  }

  void dispose() {
    _marketsRefreshController.close();
    _audMarketsRefreshController.close();
    _btcMarketsRefreshController.close();
    _favMarketsRefreshController.close();
    _pageLoading.close();
  }
}
