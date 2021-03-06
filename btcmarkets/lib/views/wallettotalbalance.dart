import 'dart:async';

import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/viewmodels/appdatamodel.dart';
import 'package:flutter/material.dart';

class WalletTotalBalanceView extends StatefulWidget {
  WalletTotalBalanceView({Key key, this.inBtc}) : super(key: key);

  final bool inBtc;

  @override
  _WalletTotalBalanceViewState createState() => _WalletTotalBalanceViewState();
}

class _WalletTotalBalanceViewState extends State<WalletTotalBalanceView>
    with AutomaticKeepAliveClientMixin<WalletTotalBalanceView> {
  _WalletTotalBalanceViewState();

  @override
  bool get wantKeepAlive => true;

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

    var bigStyle = Theme.of(context).textTheme.headline;
    var subStyle = Theme.of(context).textTheme.subhead;
    var hintStyle = bigStyle.copyWith(color: Theme.of(context).hintColor);
    var currency = widget.inBtc ? "BTC" : "AUD";

    
          return FutureBuilder(
            future: model.getTotalBalanceString(widget.inBtc),
            builder:
                (BuildContext buildContext, AsyncSnapshot<String> snapshot) {
              var data = snapshot.data;
              return Wrap(
                direction: Axis.vertical,
                spacing: 5,
                children: <Widget>[
                  Text(
                    "Total Holdings",
                    style: subStyle,
                  ),
                  Wrap(
                    direction: Axis.horizontal,
                    spacing: 5,
                    children: <Widget>[
                      Text(currency, style: bigStyle),
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                              text: MarketHelper.getSymbol(currency),
                              style: hintStyle),
                          TextSpan(text: data, style: bigStyle)
                        ]),
                      )
                    ],
                  )
                ],
              );
            },
          );
       
  }
}
