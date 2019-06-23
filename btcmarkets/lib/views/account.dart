import 'package:btcmarkets/api/btcmarketsapi.dart';
import 'package:btcmarkets/views/fundshistory.dart';
import 'package:btcmarkets/views/openorders.dart';
import 'package:btcmarkets/views/walletbalances.dart';
import 'package:flutter/material.dart';
import 'apppopupmenu.dart';
import 'navdrawar.dart';
import 'orderhistory.dart';


class AccountView extends StatefulWidget {
  AccountView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {

  NavDrawer _navDrawer =  new NavDrawer();
  AppPopupMenu _popupMenu = new AppPopupMenu();
  int _selectedIndex = 0;

  _AccountViewState();

  @override
  Widget build(BuildContext context) {

    return  DefaultTabController(
      initialIndex: _selectedIndex,
      length: 4,
      child:  Scaffold(
           drawer: _navDrawer,
           appBar:  new AppBar(
             title: Text("Account"),
             actions: <Widget>[_popupMenu],
            bottom: TabBar(
               isScrollable: true,
               
               tabs: [
                 Tab(text: "Balances",),
                 Tab(text: "Open Orders"),
                 Tab(text: "Order History"),
                 Tab(text: "Fund History"),
               ],
             ),

           ),
           body:  TabBarView(children: <Widget>[
              WalletBalancesView(),
              OpenOrdersView(),
              OrderHistoryView(),
              FundsHistoryView()
           ],)

       ),

    );

  }
}
