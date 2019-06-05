import 'dart:async';
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

  bool isLoading = false;

  final StreamController<String> _marketsRefreshController =
      StreamController<String>.broadcast();

  StreamSink<String> get marketsRefreshSink => _marketsRefreshController.sink;
  Stream<String> get marketsRefreshStream => _marketsRefreshController.stream;

  AppDataModel() {
    _api = new BtcMarketsApi();
  }

  Future refreshMarkets() async {
    debugPrint('Refreshing');

    isLoading = true;  
    marketsRefreshSink.add("");

    var data = await _api.getMarkets();

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

    markets.sort((a,b)=> a.groupId.compareTo(b.groupId));
    isLoading = false;
     marketsRefreshSink.add("Refresh");
  }

  void dispose() {
    _marketsRefreshController.close();
  }
}
