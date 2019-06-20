import 'package:btcmarkets/models/popupchoice.dart';
import 'package:btcmarkets/views/apppopupmenu.dart';
import 'package:btcmarkets/views/settings.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
   
    return new Scaffold(
        drawer: _navDrawer,
        appBar: new AppBar(
          title: Text("Home"),
          actions: <Widget>[
           _popupMenu
          ],
        ),
        body: new Text("Home"));
  }
}
