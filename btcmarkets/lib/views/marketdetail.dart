import 'dart:convert';

import 'package:btcmarkets/api/btcmarketsapi.dart';
import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:btcmarkets/helpers/uihelpers.dart';
import 'package:btcmarkets/models/marketdata.dart';
import 'package:btcmarkets/models/markethistory.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_candlesticks/flutter_candlesticks.dart';
import '../constants.dart';
import 'navdrawar.dart';
import 'marketlist.dart';

class MarketDetailView extends StatefulWidget {
  MarketDetailView({Key key, this.market}) : super(key: key);

  final MarketData market;

  @override
  _MarketDetailState createState() => _MarketDetailState();
}

class _MarketDetailState extends State<MarketDetailView> {
  MarketData market;
  var _history = [];
  String _high, _low;
  var duration = "1D";
  void refreshHistory(String dur) {

      duration = dur;
    
    setState(()  {
     
    });
  }

  @override
  void initState() {
    super.initState();
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance
          .addPostFrameCallback((_) => updateHighLow(context));
    }
  }

  void updateHighLow(BuildContext context) {
    print("loaded frame");
  }

  void _loadHistory() async {
    _history.clear();
    var model = AppDataProvider.of(context).model;
    var history = model.marketHistory;
    if (history.isEmpty) {
      await model.refreshMarketHistory(widget.market, "1D");
      history = model.marketHistory;
    }

    if (history.isNotEmpty) {
      double high = 0.0;
      double low = history[0].low;
      for (var h in history) {
        _history.add({
          "open": h.open,
          "close": h.close,
          "high": h.high,
          "low": h.low,
          "volumeto": h.volumeto
        });
        if (h.high > high) high = h.high;

        if (h.low < low) low = h.low;
      }

      _high = high.toString();
      _low = low.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    var model = AppDataProvider.of(context).model;

    //  _loadHistory();

    var market = widget.market;
    var marketPair = "${market.instrument}/${market.currency}";
    var accentColor = Theme.of(context).accentColor;
    var hintColor = Theme.of(context).hintColor;

    var defaultTextStyle = Theme.of(context).textTheme.body1;
    var bigStyle = Theme.of(context).textTheme.headline;
   
    return Scaffold(
        appBar: new AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image.asset(
                "assets/images/${market.instrument.toLowerCase()}.png",
                width: 24,
                height: 24,
              ),
              SizedBox(
                width: 5,
              ),
              Text("${market.name} (${market.instrument})")
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.fromLTRB(10, 30, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[

                //Details
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Row(children: [
                        Text(market.currency, style: bigStyle),
                        SizedBox(
                          width: 5,
                        ),
                        RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: market.getSymbol(),
                                style: bigStyle.copyWith(color: hintColor)),
                            TextSpan(text: market.priceString, style: bigStyle)
                          ]),
                        ),
                      ]),
                      SizedBox(height: 40),
                      Row(
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Bid ",
                                      style: TextStyle(color: accentColor)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: market.getSymbol(),
                                          style: TextStyle(color: hintColor)),
                                      TextSpan(
                                          text: market.bidString,
                                          style: defaultTextStyle)
                                    ]),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Ask",
                                      style: TextStyle(color: accentColor)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: market.getSymbol(),
                                          style: TextStyle(color: hintColor)),
                                      TextSpan(
                                          text: market.askString,
                                          style: defaultTextStyle)
                                    ]),
                                  )
                                ],
                              )
                            ],
                          ),
                          SizedBox(
                            width: 25,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("High",
                                      style: TextStyle(color: accentColor)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: market.getSymbol(),
                                          style: TextStyle(color: hintColor)),
                                      TextSpan(
                                          text: _high, style: defaultTextStyle)
                                    ]),
                                  )
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Low ",
                                      style: TextStyle(color: accentColor)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: market.getSymbol(),
                                          style: TextStyle(color: hintColor)),
                                      TextSpan(
                                          text: _low, style: defaultTextStyle)
                                    ]),
                                  )
                                ],
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: 30),
                //Charting
                Container(
                  child: Column(
                    children: <Widget>[
                      SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          FlatButton( 
                            padding: EdgeInsets.all(0),
                            child: Text("1H"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("3H"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("12H"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("1D"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("3D"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("1W"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("2W"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("1M"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("3M"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("6D"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("1Y"), onPressed: (){
                            refreshHistory("1H");
                          }),
                          FlatButton( child: Text("ALL"), onPressed: (){
                            refreshHistory("1H");
                          })
                        ],
                      ),
                      ),
                      SizedBox(height: 20),
                      Container(
                          height: 250,
                          child: FutureBuilder(
                            future:
                                model.getMarketHistory(widget.market, duration),
                            builder: (BuildContext buildContext,
                                AsyncSnapshot<List<MarketHistory>> snapshot) {
                              if (snapshot.hasData) {
                                var data = snapshot.data.reversed.toList();
                                var history = [];

                                if (data.length > 0) {
                                  double high = 0.0;
                                  double low = data[0].low;

                                  for (var h in data) {
                                    history.add({
                                      "open": h.open,
                                      "close": h.close,
                                      "high": h.high,
                                      "low": h.low,
                                      "volumeto": h.volumeto
                                    });
                                    if (h.high > high) high = h.high;
                                    if (h.low < low) low = h.low;
                                  }
                                  _history = history;
                                  _high = high.toString();
                                  _low = low.toString();

                                  return OHLCVGraph(
                                      data: history,
                                      enableGridLines: true,
                                      gridLineColor: hintColor,
                                      volumeProp: 0.2);
                                } else {
                                  _high = "";
                                  _low = "";
                                  return Center(
                                      child: Text("No data available."));
                                }
                              }
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget getHeaderView(String header, String value, Color headerColor) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(text: "$header ", style: TextStyle(color: headerColor)),
        TextSpan(text: "$value", style: TextStyle(color: Text("").style.color))
      ]),
    );
  }

  Widget getSymbolValueView(String symbol, String value, Color symbolColor) {
    return RichText(
      text: TextSpan(children: [
        TextSpan(text: "$symbol", style: TextStyle(color: symbolColor)),
        TextSpan(text: "$value", style: TextStyle(color: Text("").style.color))
      ]),
    );
  }
}
