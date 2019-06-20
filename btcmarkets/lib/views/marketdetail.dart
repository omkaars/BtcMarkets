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
 
  var duration="1D";
  void refreshHistory(String dur) async {
    duration = dur;
    var model = AppDataProvider.of(context).model;
    await model.refreshMarketHistory(widget.market, duration);


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

  void updateHighLow(BuildContext context){
     refreshHistory("1D");
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

    var chartPeriods = ["1H","6H","12H","1D","3D","1W","2W","1M","3M","6M","1Y","3Y","ALL"];

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
              Text("${market.name}")
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
                      SizedBox(height: 20),
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
                          StreamBuilder(
                            stream: model.marketHistoryStream,
                            builder: (BuildContext buildContext,
                                AsyncSnapshot<String> snapshot) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              style:
                                                  TextStyle(color: hintColor)),
                                          TextSpan(
                                              text: model.marketHistory.highString,
                                              style: defaultTextStyle)
                                        ]),
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              style:
                                                  TextStyle(color: hintColor)),
                                          TextSpan(
                                              text: model.marketHistory.lowString,
                                              style: defaultTextStyle)
                                        ]),
                                      )
                                    ],
                                  )
                                ],
                              );
                            },
                          )
                        ],
                      )
                    ],
                  ),
                ),

                SizedBox(height: 20),


                //Charting
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                       
                      Container(
                        height: 30,
                      
                        padding: EdgeInsets.all(0),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: chartPeriods.length,
                        itemBuilder: (BuildContext buildContext, int index){
                          var period = chartPeriods[index];
                          return Container(
                            width:50,
                             decoration: (duration == period)?  BoxDecoration(
                                color: accentColor,
                                borderRadius: BorderRadius.all(Radius.circular(10.0)),
                             ): null,
                            padding: EdgeInsets.all(0),
                            
                            child:FlatButton(
                              padding: EdgeInsets.all(0),
                            child: Text(period, style: Theme.of(context).textTheme.subhead,),
                            onPressed: (){
                                setState((){
                                refreshHistory(period);
                                });
                                
                            },
                          ));
                        },
                      ),
                      ),
                      SizedBox(height: 20),
                      AspectRatio(aspectRatio: 3/2,
                      child:
                      Container(
                          
                          child: StreamBuilder(
                            stream: model.marketHistoryStream,
                            builder: (BuildContext buildContext,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.hasData) {
                                if (model.marketHistory.data.isNotEmpty) {
                                  var data = model.marketHistory.data.reversed
                                      .toList();

                                  return OHLCVGraph(
                                      data: data,
                                      enableGridLines: true,
                                      gridLineColor: hintColor,
                                      volumeProp: 0.2);
                                } else {
                                  return Center(
                                      child: Text("No data available."));
                                }
                              }
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                          )
                          )
                          )
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
