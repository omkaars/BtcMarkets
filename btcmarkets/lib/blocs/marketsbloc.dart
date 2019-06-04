import 'dart:async';
import '../api/btcmarketsapi.dart';
import 'package:flutter/material.dart';

class MarketDataBloc {

  final _api = new BtcMarketsApi();

   final StreamController<List<Market>> _marketsDataController =  StreamController<List<Market>>.broadcast();



  StreamSink<List<Market>> get marketDataSink => _marketsDataController.sink;
  Stream<List<Market>> get marketDataStream => _marketsDataController.stream;

 MarketDataBloc()
 {

 }

 refreshMarkets() async
 {
   marketDataSink.add(null);
   Future.delayed(const Duration(seconds: 1), () => "5");
    var markets = await _api.getMarkets();
    if(markets.success) {
      marketDataSink.add(markets.markets);
    }
    else
      {
        marketDataSink.addError(markets.errorMessage);
      }
 }

 dispose()
  {
    if(_marketsDataController != null)
      {
        _marketsDataController.close();
      }

  }

}

class MarketDataBlocProvider extends InheritedWidget
{
  final MarketDataBloc bloc;
  final Widget child;

  MarketDataBlocProvider({this.bloc, this.child}) : super(child: child);
  static MarketDataBlocProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(MarketDataBlocProvider);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }

}