import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class MarketWebView extends StatefulWidget {
  
  MarketWebView({Key key, this.title, this.url}) : super(key: key);
  
  final String title;
  final String url;

  @override
  _MarketWebState createState() => _MarketWebState();
}

class _MarketWebState extends State<MarketWebView> {
  @override
  Widget build(BuildContext context) {
    return new WebviewScaffold(
      url: widget.url,
      appBar: new AppBar(
        title: Text(widget.title),
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
        child: const Center(
          child: CircularProgressIndicator()
        ),
      ),
    );
  }
}
