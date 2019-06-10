import 'dart:async';

import 'package:btcmarkets/models/marketdata.dart';

import 'package:flutter/material.dart';

import 'markettext.dart';

class MarketPair extends StatefulWidget {
  MarketPair({Key key, this.market}) : super(key: key);
  final StreamController<MarketData> changeMarketNotifier = new StreamController<MarketData>.broadcast();

  final MarketData market;

  @override
  _MarketPairState createState() => _MarketPairState();

  void marketChange(MarketData m)
  {
    if(m != null)
      changeMarketNotifier.sink.add(m);
  }
  void dispose()
  {
    changeMarketNotifier.close();
  }

}

class _MarketPairState extends State<MarketPair> with AutomaticKeepAliveClientMixin<MarketPair>
{
  _MarketPairState();
  MarketData _market;
  MarketText _price, _volume;
  StreamSubscription _notification;

  @override
  void initState()
  {
    super.initState();

    _market = this.widget.market;
      _notification = widget.changeMarketNotifier.stream.listen((market){
      changeMarket(market);
    });
  }
  
  bool isCurrentMarket(MarketData market)
  {
    return _market != null && market != null && _market.pair == market.pair;
  }

  void setMarket(MarketData market)
  {
    setState(() {
     _market = market; 
    });
  }

  void changeMarket(MarketData market)
  {
    if(!isCurrentMarket(market))
    {
      return;
    }
    
    if(_market.lastPrice != market.lastPrice)
    {
      _price.setText(market.lastPrice.toString());
    }

    if(_market.volume24h != market.volume24h)
    {
      _volume.setText(market.volume24h.toString());
    } 
  }

  void setPrice(String price)
  {
    _price.setText(price);
  }
  void setVolume(String volume)
  {
    _volume.setText(volume);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose()
  {
    super.dispose();
    if(_notification != null)
    {
      _notification.cancel();
    }
  }

  Widget _getMarketPair()
  {
    var market = _market;
    _price = MarketText(text:market.lastPrice.toString());
    _volume = MarketText(text:market.volume24h.toString());
      var item = InkWell(

               child: Container(
                 padding: EdgeInsets.all(10),
                 child:

                 Row(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: <Widget>[
                     Expanded(
                         flex:3,
                         
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: <Widget>[
                          
                         Row( 
                           mainAxisAlignment: MainAxisAlignment.start,
                           
                           children: <Widget>[
                             Image.asset("assets/images/${market.instrument.toLowerCase()}.png", width: 24, height: 24, ),
                             Spacer(flex:4),
                            Expanded(
                            flex:80,
                            child: Text(market.instrument, style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                           )
                         ],),
                         
                         Text(market.name, textAlign: TextAlign.start, )

                         ],)
                         
                     ),
                     Expanded(
                         flex:3,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: <Widget>[
                             _price,
                             _volume
                           ],
                         )
                     ),
                     Expanded(
                         flex:3,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: <Widget>[
                            _price,
                            _volume
                           ],
                         )
                     ),
                     Expanded(
                       flex: 1,
                       child: Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: <Widget>[
                             Icon(
                               Icons.favorite_border,
                               
                               color: Theme.of(context).accentColor),
                              Icon(
                               Icons.notifications_none,
                              
                               color: Theme.of(context).primaryColor),
                           ],
                         )
                     )
                   ],
                 ),
               )
           );

    
    return item;
  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
   
    return _getMarketPair();
  }

}
