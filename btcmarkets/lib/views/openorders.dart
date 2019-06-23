import 'package:btcmarkets/models/marketdata.dart';
import 'package:btcmarkets/models/walletcurrency.dart';
import 'package:btcmarkets/models/walletorder.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/views/marketdetail.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class OpenOrdersView extends StatefulWidget {
  OpenOrdersView({Key key, this.group}) : super(key: key);

  final String group;

  @override
  _OpenOrdersViewState createState() => _OpenOrdersViewState();
}

class _OpenOrdersViewState extends State<OpenOrdersView>
    with AutomaticKeepAliveClientMixin<OpenOrdersView> {
  _OpenOrdersViewState();

  @override
  bool get wantKeepAlive => true;

  bool _hideZeroBalance = false;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var model = AppDataProvider.of(context).model;

    var accentColor = Theme.of(context).accentColor;
    var defaultTextStyle = Theme.of(context).textTheme.body1;
    var bigStyle = Theme.of(context).textTheme.subtitle;
    var hintColor = Theme.of(context).hintColor;
    var hintStyle = TextStyle(color: hintColor);
    return FutureBuilder(
        future: model.getOpenOrders(),
        builder: (BuildContext buildContext,
            AsyncSnapshot<List<WalletOrder>> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if(snapshot.hasError)
          {
            return Center(child: Text("Something went wrong. Please retry after sometime."),);
          }
          var orders = snapshot.data;

          var header = Container(
              color: Theme.of(context).accentColor,
              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
              child: Row(children: <Widget>[
                Expanded(flex: 4, child: Text("Date")),
                Expanded(flex: 7, child: Text("Coin")),
                Expanded(flex: 3, child: Text("Price/Vol")),
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
                      return model.getOpenOrders();
                    },
                    child: ListView.separated(
                      separatorBuilder: (BuildContext buildContext, int index) {
                        return Divider(height: 1);
                      },
                      itemCount: orders.length,
                      itemBuilder: (BuildContext buildContext, int index) {
                        var order = orders[index];

                        return Container(
                            padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 4,
                                    child: 
                                    Wrap(
                                      direction: Axis.vertical,
                                      children: <Widget>[
                                        Text(order.createdString),
                                        Text(order.status, style: hintStyle)
                                      ],
                                    )
                                    // Column(
                                    //   crossAxisAlignment:
                                    //       CrossAxisAlignment.start,
                                    //   children: <Widget>[
                                    //     Text(order.createdString),
                                    //     Text(order.status, style: hintStyle)
                                    //   ],
                                    // )
                                    
                                    ),
                                Expanded(
                                    flex: 3,
                                    child: 
                                    Wrap(
                                      direction: Axis.vertical,
                                      children: <Widget>[
                                            Text(order.pair),
                                          Text(
                                            order.sideType,
                                            style: hintStyle,
                                          ),
                                      ],
                                      )
                                    
                                    // Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: <Widget>[
                                    //       Text(order.pair),
                                    //       Text(
                                    //         order.sideType,
                                    //         style: hintStyle,
                                    //       ),
                                    //     ])
                                        
                                        ),
                                Expanded(
                                    flex: 6,
                                    child: 
                                    Container(
                                      alignment: Alignment.centerRight,
                                    child:Wrap(
                                      direction: Axis.vertical,
                                      alignment: WrapAlignment.start,
                                      crossAxisAlignment: WrapCrossAlignment.end,
                                        children: <Widget>[
                                          Text(order.priceString),
                                          Text(
                                            order.volumeString,
                                            style: hintStyle,
                                          )
                                        ]
                                    )
                                    )
                                    
                                    // Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.end,
                                    //     children: <Widget>[
                                    //       Text(order.priceString),
                                    //       Text(
                                    //         order.volumeString,
                                    //         style: hintStyle,
                                    //       )
                                    //     ])
                                        ),
                                Expanded(
                                    flex: 1,
                                    child: IconButton(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      alignment: Alignment.topCenter,
                                      icon: Icon(Icons.cancel,
                                          color: Colors.redAccent),
                                      onPressed: () {},
                                    ))
                              ],
                            ));

                        // return ExpansionTile(title: header,
                        // children: <Widget>[
                        //   Text(order.total.toString())
                        // ],
                        // );
                      },
                    ),
                  ))
            ],
          ));

          return widget;
        });
  }
}
