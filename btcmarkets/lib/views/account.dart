import 'package:flutter/material.dart';
import 'navdrawar.dart';


class AccountView extends StatefulWidget {
  AccountView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AccountViewState createState() => _AccountViewState();
}

class _AccountViewState extends State<AccountView> {

  NavDrawer _navDrawer =  new NavDrawer();

  _AccountViewState();

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        drawer: _navDrawer,
        appBar:  new AppBar(
            title: Text("Account")
        ),
        body: new Text("Account")

    );
  }
}
