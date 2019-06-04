import 'package:flutter/material.dart';
import 'navdrawar.dart';

class SettingsView extends StatefulWidget {


  SettingsView();

  @override
  _SettingsViewState createState() => _SettingsViewState();

}

class _SettingsViewState extends State<SettingsView>
{
  NavDrawer _navDrawer =  new NavDrawer();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        drawer: _navDrawer,
        appBar:  new AppBar(
            title: Text("Settings")
        ),
        body: ListView(

          children: <Widget>[

            ListTile( title: Text("Api Keys")),
            Divider(height: 1),
            ListTile( title: Text("Theme")),
            ListTile( title: Text("Live Updates")),
            ListTile( title: Text("Notifications")),

          ],


        )

    );


  }
}