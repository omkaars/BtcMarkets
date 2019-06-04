import 'package:flutter/material.dart';
import 'navdrawar.dart';


class HomeView extends StatefulWidget {
  HomeView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {

  NavDrawer _navDrawer =  new NavDrawer();

  _HomeViewState();

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        drawer: _navDrawer,
        appBar:  new AppBar(
            title: Text("Home")
        ),
        body: new Text("Home")

    );
  }
}
