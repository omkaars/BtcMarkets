import 'package:btcmarkets/models/marketdata.dart';
import 'package:btcmarkets/models/walletcurrency.dart';
import 'package:btcmarkets/models/walletfundtransfer.dart';
import 'package:btcmarkets/models/walletorder.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/views/marketdetail.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class FundsHistoryView extends StatefulWidget {
  FundsHistoryView({Key key, this.group}) : super(key: key);

  final String group;

  @override
  _FundsHistoryViewState createState() => _FundsHistoryViewState();
}

class _FundsHistoryViewState extends State<FundsHistoryView>
    with AutomaticKeepAliveClientMixin<FundsHistoryView> {
  _FundsHistoryViewState();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var model = AppDataProvider.of(context).model;

    var accentColor = Theme.of(context).accentColor;
    var defaultTextStyle = Theme.of(context).textTheme.body1;
    var bigStyle = Theme.of(context).textTheme.subtitle;
    var hintColor = Theme.of(context).hintColor;
    var hintStyle = TextStyle(color: hintColor);

    var headerStyle = Theme.of(context).textTheme.body1;
    var headerTextStyle = TextStyle(fontSize: headerStyle.fontSize);
    var headerLabelStyle = TextStyle(color: hintColor);
    return FutureBuilder(
        future: model.getFundsHistory(),
        builder: (BuildContext buildContext,
            AsyncSnapshot<List<WalletFundTransfer>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          var fundTransfers = snapshot.data;

          var header = Container(
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(children: <Widget>[
                Spacer(flex:3),
                Expanded(flex: 6, child: Text("Transfer Date")),
                Expanded(flex: 3, child: Text("Coin")),
                Expanded(flex: 5, child: Text("Amount")),
              ]));

          var widget = Container(
              child: Column(
            children: <Widget>[
              header,
              // hideZeroBal,
              Expanded(
                  flex: 9,
                  child: RefreshIndicator(
                    onRefresh: () {
                      return model.getFundsHistory();
                    },
                    child: ListView.separated(
                      separatorBuilder: (BuildContext buildContext, int index) {
                        return Divider(height: 1);
                      },
                      itemCount: fundTransfers.length,
                      itemBuilder: (BuildContext buildContext, int index) {
                        var transfer = fundTransfers[index];
                        var typeStyle = headerTextStyle;
                        var transferType =
                            (transfer.transferType ?? "").toLowerCase();
                        var icon = Icons.details;
                        if (transferType == "withdraw") {
                          typeStyle =
                              headerTextStyle.copyWith(color: Colors.red.shade400);
                              icon = Icons.arrow_back;
                        } else if (transferType == "deposit") {
                          typeStyle =
                              headerTextStyle.copyWith(color: Colors.green.shade500);
                              icon = Icons.input;
                        }
                        
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
                                        Text(transfer.transferTimeString,
                                            style: typeStyle),
                                      ],
                                    )),
                                Expanded(
                                    flex: 2,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(transfer.currency,
                                              style: typeStyle),
                                        ])),
                                Expanded(
                                    flex: 6,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(transfer.amountString,
                                              style: typeStyle),
                                        ])),
                              ],
                            ));

                        return ExpansionTile(
                          title: header,
                          leading: Icon(icon),
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                        flex: 3,
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          children: <Widget>[
                                            Text(
                                              "Type:",
                                              style: headerLabelStyle,
                                            ),
                                            Text(transfer.transferType, style: headerLabelStyle)
                                          ],
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          children: <Widget>[
                                            Text("Status:",
                                                style: headerLabelStyle),
                                            Text(transfer.status, style: headerLabelStyle)
                                          ],
                                        )),
                                    Expanded(
                                        flex: 3,
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          children: <Widget>[
                                            Text("Fee:", style: headerLabelStyle),
                                            Text(transfer.feeString, style: headerLabelStyle)
                                          ],
                                        ))
                                  ],
                                )),
                            Padding(
                                padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                                child: Text(transfer.description.toString(), style: headerLabelStyle))
                          ],
                        );
                      },
                    ),
                  ))
            ],
          ));

          return widget;
        });
  }
}
