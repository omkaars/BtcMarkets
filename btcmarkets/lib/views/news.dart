import 'package:btcmarkets/models/newsitem.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:flutter/material.dart';
import 'navdrawar.dart';

class NewsView extends StatefulWidget {
  NewsView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  NavDrawer _navDrawer = new NavDrawer();

  _NewsViewState();

  @override
  Widget build(BuildContext context) {
    var model = AppDataProvider.of(context).model;

    return new Scaffold(
        drawer: _navDrawer,
        appBar: new AppBar(title: Text("News")),
        body: new FutureBuilder(
            future: model.GetNews(),
            builder: (BuildContext buildContext,
                AsyncSnapshot<List<NewsItem>> snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;

                return ListView.builder(
                  itemCount : data.length,
                  itemBuilder: (context, position) {

                    var item = data[position];
                    return FlatButton(
                      padding: EdgeInsets.all(0),
                      child: Text(item.title),
                      );
                  },
                );
              }

              return Center(
                child:CircularProgressIndicator());
            }));
  }
}
