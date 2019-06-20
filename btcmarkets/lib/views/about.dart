import 'package:btcmarkets/models/popupchoice.dart';
import 'package:btcmarkets/views/apppopupmenu.dart';
import 'package:btcmarkets/views/settings.dart';
import 'package:flutter/material.dart';
import 'navdrawar.dart';

class AboutView extends StatefulWidget {
  AboutView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AboutViewState createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  
  _AboutViewState();

  @override
  Widget build(BuildContext context) {
   
    return new Scaffold(
  
        appBar: new AppBar(
          title: Text("About"),
         
        ),
        body: new Text("About"));
  }
}
