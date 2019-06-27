import 'package:btcmarkets/models/markettrades.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/viewmodels/appdatamodel.dart';
import 'package:flutter/material.dart';
import 'apppopupmenu.dart';
import 'navdrawar.dart';

class TradesView extends StatefulWidget {
  TradesView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TradesViewState createState() => _TradesViewState();
}

class _TradesViewState extends State<TradesView> {
  NavDrawer _navDrawer = new NavDrawer();
  AppPopupMenu _popupMenu = new AppPopupMenu();
  _TradesViewState();

  bool _isFirst = true;
  String instrument = "BTC";
  String currency = "AUD";
  @override
  Widget build(BuildContext context) {
    var model = AppDataModel();

    return new Scaffold(
        drawer: _navDrawer,
        appBar: new AppBar(
          title: Text("Trades"),
          actions: <Widget>[_popupMenu],
        ),
        body: getTradesView());
  }

  Widget getTradesView() {
    var model = AppDataModel();

    return FutureBuilder(
      //stream: model.tradesRefreshStream,
      future: model.getTrades(instrument, currency),
      builder:
          (BuildContext buildContext, AsyncSnapshot<MarketTrades> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var asks = model.marketTrades.asks;
        var bids = model.marketTrades.bids;
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Container(child: Text("Top")),
              getOrderHeader(),
              Expanded(flex: 4, child: getOrdersView(asks, true)),
              Container(
                height: 30,
                color: Theme.of(context).highlightColor,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Text("Bid"),
                    ),
                    Expanded(flex: 5, child: Text("Ask"))
                  ],
                ),
              ),
              Expanded(flex: 4, child: getOrdersView(bids, false)),
            ],
          ),
        );
      },
    );
  }

  Widget getOrderHeader() {
    return Container(
        color: Theme.of(context).accentColor,
        padding: EdgeInsets.all(5),
        child: Row(children: <Widget>[
          Expanded(
            flex: 3,
            child:
                Align(alignment: Alignment.centerRight, child: Text("Price")),
          ),
          Expanded(
            flex: 4,
            child:
                Align(alignment: Alignment.centerRight, child: Text("Amount")),
          ),
          Expanded(
              flex: 4,
              child:
                  Align(alignment: Alignment.centerRight, child: Text("Total")))
        ]));
  }

  Widget getOrdersView(List<MarketOrderData> orders, bool isSell) {
    var textStyle = TextStyle(
      color: Theme.of(context).hintColor,
    );

    var color = isSell ? Colors.red : Colors.green;

    var orderStyle = TextStyle(color: color);

    var details = Expanded(
        flex: 8,
        child: ListView.separated(
          reverse: isSell,
          shrinkWrap: true,
          separatorBuilder: (BuildContext buildContext, int index) {
            return Divider(height: 1);
          },
          itemCount: orders.length,
          itemBuilder: (BuildContext buildContext, int index) {
            var data = orders[index];
            return Container(
                padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
                child: Row(children: <Widget>[
                  Expanded(
                      flex: 4,
                      child: Align(
                          alignment: Alignment.topRight,
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: data.priceSymbol, style: textStyle),
                              TextSpan(
                                  text: data.priceString, style: orderStyle)
                            ]),
                          ))),
                  Expanded(
                      flex: 5,
                      child: Align(
                          alignment: Alignment.topRight,
                          child: RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                  text: data.amountSymbol, style: textStyle),
                              TextSpan(
                                  text: data.amountString, style: orderStyle)
                            ]),
                          ))),
                  //Text(data.amountString, style: textStyle)),
                  Expanded(
                    flex: 4,
                    child: Align(
                        alignment: Alignment.topRight,
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(text: data.totalSymbol, style: textStyle),
                            TextSpan(text: data.totalString, style: textStyle)
                          ]),
                        )),
                  )
                ]));
          },
        ));

    return Container(
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
          Container(
              padding: EdgeInsets.all(2),
              color: color,
              child: Align(
                  alignment: Alignment.center,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text(isSell ? "Sell" : "Buy"),
                  ))),
          Expanded(
              flex: 9,
              child: Column(
                children: <Widget>[details],
              ))
        ]));
  }
}
