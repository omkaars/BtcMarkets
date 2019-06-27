import 'package:btcmarkets/models/navview.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/viewmodels/appdatamodel.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'apppopupmenu.dart';
import 'navdrawar.dart';
import 'marketlist.dart';

class MarketsView extends StatefulWidget {
  MarketsView();

  @override
  _MarketsViewState createState() => _MarketsViewState();
}

class _MarketsViewState extends State<MarketsView> {
  NavDrawer _navDrawer = new NavDrawer();
 AppPopupMenu _popupMenu = new AppPopupMenu();
  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    var model = AppDataModel();
 
    if (model.markets.length <= 0) {
      model.refreshMarkets();
    }

    switch (model.view.subView) {
      case SubView.MarketFavourites:
        _selectedIndex = 0;
        break;
      case SubView.MarketAudMarkets:
        _selectedIndex = 1;
        break;
      case SubView.MarketBtcMarkets:
        _selectedIndex = 2;
        break;
      default:
        if (model.favourites.length > 0) {
          _selectedIndex = 0;
        } else {
          _selectedIndex = 1;
        }
        break;
    }
    //print("SelectedIndex -->>> $_selectedIndex");

    //print("In Build $_selectedIndex");
    var controller = new DefaultTabController(
      initialIndex: _selectedIndex,
      length: 3,
      child: Scaffold(
          drawer: _navDrawer,
          appBar: new AppBar(
            title: Text("Markets"),
            bottom: TabBar(
              isScrollable: true,
              
              tabs: [
                Tab(
                  text: "Favourites",
                ),
                Tab(text: "AUD Markets"),
                Tab(text: "BTC Markets"),
              ],
            ),
             actions: <Widget>[
           _popupMenu
          ],
          ),
          body: TabBarView(
            children: <Widget>[
              MarketList(
                group: Constants.Favourites,
              ),
              MarketList(
                group: Constants.AudMarkets,
              ),
              MarketList(
                group: Constants.BtcMarkets,
              ),
            ],
          )),
    );

    
    return controller;
  }
}
