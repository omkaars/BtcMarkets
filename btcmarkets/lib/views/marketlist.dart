import 'package:btcmarkets/models/marketdata.dart';
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

  List<MarketPair> _marketPairs;

  @override
  void initState()
  {
    super.initState();
    _marketPairs = new List<MarketPair>();
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
       var item = new MarketPair(market: market,);
        _marketPairs.add(item);
        
        list.add(item);
        if(index < count-1)
          list.add(Divider(height: 1,));

        index++;
     }
    return list;
  }
  Widget _buildUI()
  {

    var model = AppDataProvider.of(context).model;
    var marketsGroups = model.marketsGroups;
      print("Calling buildUI");
      Color _titleColor = Theme.of(context).accentColor;
      Color _textColor = Colors.white;

      List<SliverStickyHeader> stickyHeaders = new List<SliverStickyHeader>();
      for(var marketGroup in marketsGroups)
      {
       
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
