import 'package:btcmarkets/models/marketdata.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/views/marketdetail.dart';
import 'package:flutter/material.dart';
import '../constants.dart';


class MarketList extends StatefulWidget {
  MarketList({Key key, this.group}) : super(key: key);

  final String group;

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
    await AppDataProvider.of(context).model.refreshMarkets(isPullToRefesh: true);
    return null;
  }

  void setFavourite(MarketData market)
  {
    setState((){
      market.isStarred = !market.isStarred;
       var model = AppDataProvider.of(context).model;
       model.updateFavourite(market, market.isStarred);
    });
  }
  
  void showMarketDetail(MarketData market) async
  {
       var model = AppDataProvider.of(context).model;
      // await model.refreshMarketHistory(market, "1D");
      var marketDetail = new MarketDetailView(market: market);
      Navigator.push(context,  MaterialPageRoute(builder: (context) => marketDetail));
  }
  Widget _buildUI()
  {

    var model = AppDataProvider.of(context).model;
   
    debugPrint("Calling buildUI");
   
    List<MarketData> markets = new List<MarketData>();
    if(widget.group == Constants.BtcMarkets)
    {
       markets = model.btcMarkets;
    }
    else
    if(widget.group == Constants.AudMarkets)
    {
      markets = model.audMarkets;
    }
    if(widget.group == Constants.Favourites)
    {
      markets = model.favMarkets;
    }
  
  var accentColor = Theme.of(context).accentColor;
  var defaultTextStyle = Theme.of(context).textTheme.body1;
  var bigStyle = Theme.of(context).textTheme.subtitle;
  var hintColor = Theme.of(context).hintColor;

   var listView = ListView.separated(
        separatorBuilder: (context, length)=> Divider(height: 1),
        scrollDirection: Axis.vertical,
        itemCount: markets == null ?  0 : markets.length,
         itemBuilder: (BuildContext context, int index){
        
           var market = markets[index];
           return InkWell(
                onTap: (){
                  showMarketDetail(market);
                },
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
                            child: Text(market.instrument, style: bigStyle,
                            ),
                           )
                         ],),
                         
                         Text(market.name, textAlign: TextAlign.start, style:TextStyle(color:hintColor) )

                         ],)
                         
                     ),
                     Expanded(
                         flex:3,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: <Widget>[
                             RichText(
                              text: TextSpan( children: [
                                TextSpan(text: market.getSymbol(), style: TextStyle(color: hintColor)),
                                TextSpan(text: market.priceString, style: defaultTextStyle)
                              ]),
                            ),
                             Text(market.volume24h.toString(), style: TextStyle(color: hintColor))
                           ],
                         )
                     ),
                     Expanded(
                         flex:3,
                         child: Column(
                           crossAxisAlignment: CrossAxisAlignment.end,
                           children: <Widget>[
                            Text(market.holdings.toString()),
                            Text(market.volume24h.toString(), style: TextStyle(color: hintColor))
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
                               icon: new Icon(market.isStarred?Icons.favorite:Icons.favorite_border,color: Theme.of(context).hintColor), 
                               
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
         },

   );

  
    return
            RefreshIndicator(
                displacement: 100,

                onRefresh: ()=> _onRefresh(),
                child: Container(
                    child: Column(children: <Widget>[
                      Container(
                        color: Theme.of(context).accentColor,
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child:Row(
                                        children:<Widget>[
                                          Expanded(flex:7, child:Text("Coin")),
                                          Expanded(flex:5, child:Text("Price")),
                                         Expanded(flex:4, child:Text("Holdings")),
                                        ]
                                      )
                      ),

                      Expanded(flex:8,
                      
                      child: listView,)

                    ],)
                  
                  ,) 
                
                
                
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
