import 'package:btcmarkets/models/marketdata.dart';
import 'package:btcmarkets/models/marketsgroup.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';

import 'package:flutter/material.dart';

import 'marketpair.dart';

class MarketList extends StatefulWidget {
  MarketList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MarketListState createState() => _MarketListState();
}

class _MarketListState extends State<MarketList> with AutomaticKeepAliveClientMixin<MarketList>
{
  _MarketListState();

  @override
  void initState()
  {
    super.initState();
    
  }

  Future<Null> _onRefresh() async
  {
    await AppDataProvider.of(context).model.refreshMarkets();
    return null;
  }

  List<Widget> _getMarketGroupList(List<MarketData> markets)
  {
     List<Widget> list = new List<Widget>();
     var count = markets.length;
     var index = 0;
     for(var market in markets)
     {
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
                             Text(market.lastPrice.toString()),
                             Text(market.volume24h.toString())
                           ],
                         )
                     ),
                     Expanded(
                         flex:3,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: <Widget>[
                            Text(market.lastPrice.toString()),
                            Text(market.volume24h.toString())
                           ],
                         )
                     ),
                     Expanded(
                       flex: 1,
                      
                       child: 
                        Container(
                          margin: EdgeInsets.all(0),
                          
                          height: 24,
                          width: 24,
                        //Column(
                           //mainAxisAlignment: MainAxisAlignment.start,
                           //crossAxisAlignment: CrossAxisAlignment.end,
                           //children: <Widget>[
                             child: IconButton(
                               icon: new Icon(market.isStarred?Icons.favorite:Icons.favorite_border,color: Theme.of(context).accentColor), 
                               
                               onPressed: () {
                                 setFavourite(market);
                               },
                               ),
                               )
                              // Icon(
                              //  Icons.notifications_none,
                               
                              //  color: Theme.of(context).primaryColor),
                           //],
                         //)
                     )
                   ],
                 ),
               )
           );
        
        
        list.add(item);
        if(index < count-1)
          list.add(Divider(height: 1,));

        index++;
     }
    return list;
  }

  void setFavourite(MarketData market)
  {
    setState((){
      market.isStarred = !market.isStarred;
       var model = AppDataProvider.of(context).model;
       model.updateFavourite(market, market.isStarred);
    });
  }
  
  Widget _buildUI()
  {

    var model = AppDataProvider.of(context).model;
    var marketsGroups = model.marketsGroups;
      debugPrint("Calling buildUI");
     
      List<SliverStickyHeader> stickyHeaders = new List<SliverStickyHeader>();
      for(var marketGroup in marketsGroups)
      {
        
          var stickyHeader = buildGroup(marketGroup);

          stickyHeaders.add(stickyHeader);
      }

      var listView = CustomScrollView(
        slivers: stickyHeaders,
      );

    return
            RefreshIndicator(

                onRefresh: _onRefresh,
                child: listView,
            );
  }

  SliverStickyHeader buildGroup(MarketsGroup marketGroup)
  {
     Color _titleColor = Theme.of(context).accentColor;
      Color _textColor = Colors.white;

   var stickyHeader = SliverStickyHeader(
            header: Container(
              height: 40,
              padding: EdgeInsets.all(10),
              color: _titleColor,
              child: Text(
                
                marketGroup.groupName,
                style: TextStyle(color: _textColor, fontWeight: FontWeight.bold, fontSize: 16)
              ),
            ),
            sliver: new SliverList(
              
              delegate: SliverChildListDelegate(
                    _getMarketGroupList(marketGroup.markets)
                )
              ),
            );

            return stickyHeader;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var model = AppDataProvider.of(context).model;
    return new StreamBuilder(

      stream: model.marketsRefreshStream,
      initialData: [],
      builder: (BuildContext context, AsyncSnapshot snapshot){
       
        try {
          print("snapshot ${snapshot.data}");
          if (snapshot.hasError) {
            return Text(snapshot.error);
          }
          if (snapshot.hasData) {

            return  _buildUI();
          }
        }
        catch(e)
        {
          print('exception thrown***************');
          print(e);
        }
      
      },
    );
  }

  @override
 
  bool get wantKeepAlive => true;

}
