import 'package:btcmarkets/models/newsitem.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/views/marketwebview.dart';
import 'package:flutter/material.dart';
import 'apppopupmenu.dart';
import 'navdrawar.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsView extends StatefulWidget {
  NewsView({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NewsViewState createState() => _NewsViewState();
}

class _NewsViewState extends State<NewsView> {
  NavDrawer _navDrawer = new NavDrawer();
AppPopupMenu _popupMenu = new AppPopupMenu();
  _NewsViewState();

  @override
  Widget build(BuildContext context) {
    var model = AppDataProvider.of(context).model;

    return new Scaffold(
        drawer: _navDrawer,
        appBar: new AppBar(title: Text("News"),actions: <Widget>[_popupMenu],),
        body: new FutureBuilder(
            future: model.getNews(),
            builder: (BuildContext buildContext,
                AsyncSnapshot<List<NewsItem>> snapshot) {
              if (snapshot.hasData) {
                var data = snapshot.data;

                return ListView.separated(
                  separatorBuilder: (context, index){
                    return Divider(height: 1,);
                  },
                  itemCount : data.length,
                  itemBuilder: (context, position) {

                    var item = data[position];
                    return ListTile(
                      leading: Icon(Icons.open_in_new),
                      title: Text(item.title),
                      onTap: (){
                        _openUrl(item.link);
                      },
                      );
                  },
                );
              }

              return Center(
                child:CircularProgressIndicator());
            }));
  }

  void _openUrl(String url) async
  {
    var view = new MarketWebView(title: "View News", url: url,);
    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => view));
  }
}
