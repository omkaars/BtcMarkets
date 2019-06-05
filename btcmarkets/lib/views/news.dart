import 'package:flutter/material.dart';
import 'navdrawar.dart';


class NewsView extends StatefulWidget {
  NewsView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {

  NavDrawer _navDrawer =  new NavDrawer();

  _NewsViewState();

  @override
  Widget build(BuildContext context) {

    return new Scaffold(
        drawer: _navDrawer,
        appBar:  new AppBar(
            title: Text("News")
        ),
        body: new Text("News")

    );
  }
}