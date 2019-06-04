import 'package:flutter/material.dart';
import 'navdrawar.dart';

class MoreView extends StatefulWidget {
  MoreView();
  @override
  _MoreViewState createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView>
{
  NavDrawer _navDrawer =  new NavDrawer();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: _navDrawer,
        appBar:  new AppBar(
            title: Text("More")
        ),
        body: ListView(

          children: <Widget>[
            Divider(height: 1),
            ListTile( title: Text("News")),
            Divider(height: 1),
            ListTile( title: Text("Settings")),
            Divider(height: 1),
          ],
        )
    );
  }
}