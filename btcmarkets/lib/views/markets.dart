import 'package:btcmarkets/providers/appdataprovider.dart';

import '../blocs/marketsbloc.dart';
import 'package:flutter/material.dart';
import 'navdrawar.dart';
import 'marketlist.dart';

class MarketsView extends StatefulWidget {

  MarketsView();

  @override
  _MarketsViewState createState() => _MarketsViewState();

}

class _MarketsViewState extends State<MarketsView>
{


  NavDrawer _navDrawer =  new NavDrawer();


  @override
  Widget build(BuildContext context) {

    int _selectedIndex = 0;

    var model = AppDataProvider.of(context).model;
    if(    model.markets.length<=0)
      {
        model.refreshMarkets();
      }

    return new DefaultTabController(
      initialIndex: _selectedIndex,
      length: 3,
      child:  Scaffold(
           drawer: _navDrawer,
           appBar:  new AppBar(
             title: Text("Markets"),
            //  bottom: TabBar(
            //    tabs: [
            //      Tab(text: "Favourites",),
            //      Tab(text: "AUD Markets"),
            //      Tab(text: "BTC Markets"),
            //    ],
            //  ),
           ),
           body:  MarketList(),
       ),

    );
  }
}