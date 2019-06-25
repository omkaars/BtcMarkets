import 'package:btcmarkets/helpers/markethelper.dart';
import 'package:btcmarkets/models/popupchoice.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/views/apppopupmenu.dart';
import 'package:btcmarkets/views/settings.dart';
import 'package:btcmarkets/views/wallettotalbalance.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'navdrawar.dart';

class HomeView extends StatefulWidget {
  HomeView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  NavDrawer _navDrawer = new NavDrawer();
  AppPopupMenu _popupMenu = new AppPopupMenu();
  _HomeViewState();

  String _totalBalance;
  bool _totalInBtc;

  @override
  void initState() {
    super.initState();

    _totalInBtc = false;
    
  }

  Future<Null> _onRefresh() async {
    await AppDataProvider.of(context)
        .model
        .refreshMarkets(isPullToRefesh: true);
    return null;
  }

  @override
  Widget build(BuildContext context) {
      var model = AppDataProvider.of(context).model;
    
    
    return new Scaffold(
        drawer: _navDrawer,
        appBar: new AppBar(
          title: Text("Home"),
          actions: <Widget>[_popupMenu],
        ),
        body: 
        RefreshIndicator(
          onRefresh: _onRefresh,
          child: 
        ListView(
          children: [Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _totalInBtc = !_totalInBtc;
                      });
                    },
                    child: Card(
                        elevation: 10,
                        color: Theme.of(context).accentColor,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          alignment: Alignment.center,
                          child: WalletTotalBalanceView(inBtc: _totalInBtc,)
                        )),
                  ),
                )
              ]),
          ]
        )
        ,)
        );
  }
}
