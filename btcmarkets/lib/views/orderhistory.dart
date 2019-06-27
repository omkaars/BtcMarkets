import 'dart:async';

import 'package:btcmarkets/models/marketdata.dart';
import 'package:btcmarkets/models/walletcurrency.dart';
import 'package:btcmarkets/models/walletorder.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/viewmodels/appdatamodel.dart';
import 'package:btcmarkets/views/marketdetail.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class OrderHistoryView extends StatefulWidget {
  OrderHistoryView({Key key, this.group}) : super(key: key);

  final String group;

  @override
  _OrderHistoryViewState createState() => _OrderHistoryViewState();
}

class _OrderHistoryViewState extends State<OrderHistoryView>
    with AutomaticKeepAliveClientMixin<OrderHistoryView> {
  _OrderHistoryViewState();

  @override
  bool get wantKeepAlive => true;

  bool _hideZeroBalance = false;

StreamSubscription _accountStream;
  @override 
  void initState()
  {
    super.initState();
    var model = AppDataModel();
    if(_accountStream != null)
    {
      _accountStream.cancel();
    }

    _accountStream = model.accountStream.listen((data){
      setState((){});
    });

  }

  @override
  void dispose()
  {
    super.dispose();
    if(_accountStream != null)
    {
    _accountStream.cancel();
    }
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);
    var model = AppDataModel();

    var accentColor = Theme.of(context).accentColor;
    var defaultTextStyle = Theme.of(context).textTheme.body1;
    var bigStyle = Theme.of(context).textTheme.subtitle;
    var hintColor = Theme.of(context).hintColor;
    var hintStyle = TextStyle(color: hintColor);
    return Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[_getMarketList(),
          
          Expanded(flex:9,child:_refreshHistory())],
        ));
  }

  MarketData _market;

  Widget _refreshHistory() {


    var accentColor = Theme.of(context).accentColor;
    var defaultTextStyle = Theme.of(context).textTheme.body1;
    var bigStyle = Theme.of(context).textTheme.subtitle;
    var hintColor = Theme.of(context).hintColor;
    var hintStyle = TextStyle(color: hintColor);

    var headerStyle = Theme.of(context).textTheme.body1;
    var headerTextStyle = TextStyle(fontSize: headerStyle.fontSize);
    var headerLabelStyle = TextStyle(color: hintColor);
var typeStyle = headerTextStyle;
    var model = AppDataModel();
    return FutureBuilder(
      future: model.getOrderHistory(_market),
      builder:
        (BuildContext buildContext, AsyncSnapshot<List<WalletOrder>> snapshot) {
      
      if(!snapshot.hasData)
      {
        return Center(child:CircularProgressIndicator());
      }

      var history = snapshot.data;
      if(history.isEmpty)
      {
        return Center(child: Text("No data available."));
      }      
      return ListView.separated(
        itemCount: history.length,
        separatorBuilder: (BuildContext listContext, int index) {
          return Divider(
            height: 1,
          );
        },
        itemBuilder: (BuildContext listContext, int index) {
          var order = history[index];

          var header = Container(
                            padding: EdgeInsets.all(5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 8,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(order.createdString,
                                            style: typeStyle),
                                      ],
                                    )),
                                Expanded(
                                    flex: 5,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(order.priceString,
                                              style: typeStyle),
                                        ])),
                                Expanded(
                                    flex: 5,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(order.volumeString,
                                              style: typeStyle),
                                        ])),
                              ],
                            ));



          return ExpansionTile(title: header
          ,
          children: <Widget>[
            Text("ddd")
          ]);
        },
      );
    });
  }

  Widget _getMarketList() {
    var model = AppDataModel();
    var accentColor = Theme.of(context).accentColor;
    return Container(
        height: 30,

        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: model.markets.length,
          itemBuilder: (BuildContext buildContext, int index) {
            var market = model.markets[index];
            if (_market == null) {
              _market = market;
            }
            return 
            Padding(padding: EdgeInsets.symmetric(horizontal: 5), child:
            Container(
                
                decoration: (_market.pair == market.pair)
                    ? BoxDecoration(
                        color: accentColor,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      )
                    : null,
                padding: EdgeInsets.all(0),
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  child: Text(
                    market.pair,
                    style: Theme.of(context).textTheme.subhead,
                  ),
                  onPressed: () {
                    setState(() {
                      _market = market;
                      
                    });
                  },
                )));
          },
        ));
  }
}
