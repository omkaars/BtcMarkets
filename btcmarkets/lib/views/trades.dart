import 'package:flutter/material.dart';
import 'navdrawar.dart';


class TradesView extends StatefulWidget {
  TradesView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _TradesViewState createState() => _TradesViewState();
}

class _TradesViewState extends State<TradesView> {

  NavDrawer _navDrawer =  new NavDrawer();

  _TradesViewState();

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        drawer: _navDrawer,
        appBar:  new AppBar(
            title: Text("Trades")
        ),
        body: new Text("Trades")

    );
  }
}
