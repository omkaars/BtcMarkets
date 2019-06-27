import 'dart:async';

import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:btcmarkets/models/marketdata.dart';
import 'package:btcmarkets/models/walletcurrency.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/viewmodels/appdatamodel.dart';
import 'package:btcmarkets/views/marketdetail.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class WalletBalancesView extends StatefulWidget {
  WalletBalancesView({Key key, this.group}) : super(key: key);

  final String group;

  @override
  _WalletBalancesViewState createState() => _WalletBalancesViewState();
}

class _WalletBalancesViewState extends State<WalletBalancesView>
    with AutomaticKeepAliveClientMixin<WalletBalancesView> {
  _WalletBalancesViewState();

  StreamSubscription _accountStrem;

  @override
  bool get wantKeepAlive => true;

  List<WalletCurrency> _balances = new List<WalletCurrency>();

  bool _hideZeroBalance = false;

  Future<List<WalletCurrency>> _getBalances(bool refresh) async {
    var model = AppDataModel();

    if (_balances.isEmpty || refresh) {
      if (refresh && _balances.isNotEmpty) {
        _balances.clear();
      }
      var balances =
          await model.getWalletBalances(hideZeroBalance: _hideZeroBalance);
      balances.forEach((bal) {
        _balances.add(bal);
      });
    }

    return _balances;
  }

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
    return FutureBuilder(
        future: _getBalances(false),
        builder: (BuildContext buildContext,
            AsyncSnapshot<List<WalletCurrency>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var balances = snapshot.data;

          var header = Container(
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(children: <Widget>[
                Expanded(flex: 3, child: Text("Coin")),
                Expanded(flex: 3, child: 
                Align(
                        alignment: Alignment.centerRight,
                        child: Text("Balance"))
                  ),
                Expanded(
                    flex: 3,
                    child: Align(
                        alignment: Alignment.centerRight,
                        child: Text("Pending"))
                        
                        ),
              ]));

          var hideZeroBal = Container(
            child: Align(
                alignment: Alignment.centerRight,
                child: Row(
                  children: <Widget>[
                    Checkbox(
                      value: false,
                      onChanged: (val) {},
                    ),
                    Text("Hide zero balance(s)")
                  ],
                )),
          );

          var widget = Container(
              child: Column(
            children: <Widget>[
              header,
              // hideZeroBal,
              Expanded(
                  flex: 9,
                  child: RefreshIndicator(
                    onRefresh: () {
                      return _getBalances(true);
                    },
                    child: ListView.separated(
                      separatorBuilder: (BuildContext buildContext, int index) {
                        return Divider(height: 1);
                      },
                      itemCount: balances.length,
                      itemBuilder: (BuildContext buildContext, int index) {
                        var balance = balances[index];

                        Image img;
                        try {
                          img = Image.asset(
                            "assets/images/${balance.currency.toLowerCase()}.png",
                            width: 24,
                            height: 24,
                          );
                        } catch (e) {
                          print(e);
                          img = Image.asset(
                            "assets/images/aud.png",
                            width: 24,
                            height: 24,
                          );
                        }
                        return Container(
                            padding: EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  flex: 3,
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    spacing: 3,
                                    children: <Widget>[
                                      Wrap(
                                        alignment: WrapAlignment.start,
                                        spacing: 5,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        direction: Axis.horizontal,
                                        children: <Widget>[
                                          img,
                                          Text(
                                            balance.currency,
                                            style: bigStyle,
                                          )
                                        ],
                                      ),
                                      Text(balance.name ?? "",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(color: hintColor))
                                    ],
                                  ),
                                  // Column(
                                  //   crossAxisAlignment: CrossAxisAlignment.start,
                                  //   children: <Widget>[

                                  //     Row(
                                  //       mainAxisAlignment:
                                  //           MainAxisAlignment.start,
                                  //       children: <Widget>[
                                  //         img,

                                  //         Expanded(
                                  //           flex: 5,
                                  //           child: Padding(
                                  //               padding: EdgeInsets.symmetric(
                                  //                   horizontal: 5),
                                  //               child: Text(
                                  //                 balance.currency,
                                  //                 style: bigStyle,
                                  //               )),
                                  //         )
                                  //       ],
                                  //     ),
                                  //     Text(balance.name ?? "",
                                  //         textAlign: TextAlign.start,
                                  //         style: TextStyle(color: hintColor))
                                  //   ],
                                  // )
                                ),
                                Expanded(
                                    flex: 3,  
                                    child: Align(
                                        alignment: Alignment.topRight,
                                        child: 
                                        RichText(text: TextSpan(children: [
                                          TextSpan(text: MarketHelper.getSymbol(balance.currency), style:TextStyle(color:hintColor)),
                                          TextSpan(text:balance.balanceString, style:defaultTextStyle)
                                        ]),)
                                        )),
                                Expanded(
                                    flex: 3,
                                    child: Align(
                                        alignment: Alignment.topRight,
                                        child: Text(balance.pendingString, style:defaultTextStyle)))
                              ],
                            ));
                      },
                    ),
                  ))
            ],
          ));

          return widget;
        });
  }

  
}
