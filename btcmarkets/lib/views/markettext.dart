import 'dart:async';
import 'package:flutter/material.dart';

class MarketText extends StatefulWidget {
  MarketText({Key key, this.text, this.style}) : super(key: key);
 
  final String text;
  final TextStyle style;
  final StreamController<String> changeTextNotifier = new StreamController<String>.broadcast();

  void setText(String text)
  {
      changeTextNotifier.sink.add(text);
  }

  @override
  _MarketTextState createState() => _MarketTextState();

  
  void dispose()
  {
    changeTextNotifier.close();
  }
}

class _MarketTextState extends State<MarketText> with AutomaticKeepAliveClientMixin<MarketText>
{
  _MarketTextState();
  String _text;
  TextStyle _style;
  Color _color;

  StreamSubscription _notification;
  @override
  void initState()
  {
    super.initState();
    _text = this.widget.text;
    _style = this.widget.style;
    _notification = widget.changeTextNotifier.stream.listen((text){
      setText(text);
    });
  }
  
  void setText(String text)
  {

    setState(() async {
      _color = Colors.red;
      _style = this.widget.style.copyWith(color: _color);
      await Future.delayed(Duration(milliseconds: 1000));
     _text = text; 
     _color = null;
     _style = this.widget.style;
    });
     
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    
   
    return Text(_text, style:_style);
  }

  @override
  void dispose()
  {
    super.dispose();
    print('in dispose');
    if(_notification != null)
    print('Notification destriying');
      _notification.cancel();
      print('destoryed');
  }

}
