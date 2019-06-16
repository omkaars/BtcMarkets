import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
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

  int _selectedIndex = 0;

 
  @override
  Widget build(BuildContext context)  {
    var model = AppDataProvider.of(context).model;
        
     if(model.markets.length<=0)
      {
         model.refreshMarkets();
      }
      if(model.favourites.length>0)
      {
        _selectedIndex = 0;
      }
      else
      {
        _selectedIndex = 1;
      }
    return new DefaultTabController(
      initialIndex: _selectedIndex,
      length: 3,
      child:  Scaffold(
           drawer: _navDrawer,
           appBar:  new AppBar(
             title: Text("Markets"),
             bottom: TabBar(
               tabs: [
                 Tab(text: "Favourites",),
                 Tab(text: "AUD Markets"),
                 Tab(text: "BTC Markets"),
               ],
             ),
           ),
           body:  TabBarView(children: <Widget>[
             MarketList(group: Constants.Favourites,),
             MarketList(group: Constants.AudMarkets,),
             MarketList(group: Constants.BtcMarkets,),
           ],)
       ),

    );
  }
}