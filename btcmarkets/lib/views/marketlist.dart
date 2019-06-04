import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/viewmodels/appdatamodel.dart';

import 'package:flutter/material.dart';

class MarketList extends StatefulWidget {
  MarketList({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MarketListState createState() => _MarketListState();
}

class _MarketListState extends State<MarketList> with AutomaticKeepAliveClientMixin<MarketList>
{



  _MarketListState();

  Future<Null> _onRefresh() async
  {

    AppDataProvider.of(context).model.refreshMarkets();
    return null;
  }


  Widget _buildUI()
  {

    var model = AppDataProvider.of(context).model;
    var markets = model.markets;
      print("Calling buildUI");
      Color _titleColor = Theme.of(context).accentColor;
      int count = 1;

//      var listView =     ListView.separated(
//        separatorBuilder: (context, length)=> Divider(height: 1),
//        scrollDirection: Axis.vertical,
//
//        itemCount: markets == null ? 1 : markets.length+1,
//        itemBuilder: (BuildContext context, int index){
//
//
//          if(index == 0)
//            {
//              return
//
//                Container(
//              height: 30,
//              color: Theme.of(context).accentColor,
//              padding: EdgeInsets.all(10),
//
//              child:
//              Row(
//
//                children: <Widget>[
//                  Expanded(
//                      flex:2,
//                      child: Text("Coin")
//                  ),
//                  Expanded(
//                      flex:4,
//                      child: Text("Price")
//                  ),
//                  Expanded(
//                      flex:4,
//                      child: Text("Volume")
//                  )
//                ],
//              ),
//             );
//
//            }
//
//          var market = markets[index];
//          return
//            InkWell(
//
//                child: Container(
//                  padding: EdgeInsets.all(10),
//                  child:
//
//                  Row(
//
//                    children: <Widget>[
//                      Expanded(
//                          flex:2,
//                          child: Text(market.instrument, style: TextStyle(fontWeight: FontWeight.bold),)
//                      ),
//                      Expanded(
//                          flex:4,
//                          child: Column(
//                            children: <Widget>[
//                              Text(market.lastPrice.toString()),
//                              Text(market.volume24h.toString())
//                            ],
//                          )
//                      ),
//                      Expanded(
//                          flex:4,
//                          child: Column(
//                            children: <Widget>[
//                              Text(market.lastPrice.toString()),
//                              Text(market.volume24h.toString())
//                            ],
//                          )
//                      )
//                    ],
//                  ),
//                )
//            );
//        },
//      );

    var listView = ListView(
          addAutomaticKeepAlives: wantKeepAlive,
          padding: EdgeInsets.all(0),
          children: <Widget>[
//            SingleChildScrollView(
//
//                scrollDirection: Axis.vertical,
//                padding: EdgeInsets.all(0),
//                child:
                DataTable(

                  columns: [

                    DataColumn(

                      label: Text("Coin", style: TextStyle(color: _titleColor, fontWeight: FontWeight.bold, fontSize: 16), ),
                      tooltip: "Coin",

                    ),
                    DataColumn(

                        label: Text("Last Price",style: TextStyle(color: _titleColor, fontWeight: FontWeight.bold,  fontSize: 16), ),
                        tooltip: "Price",

  ),
                    DataColumn(

                        label: Text("Vol",style: TextStyle(color: _titleColor, fontWeight: FontWeight.bold,  fontSize: 16), ),
                        tooltip: "Volume",


                    ),
                  ],
                  rows: AppDataProvider.of(context).model.markets.map((market)=>
                      DataRow(
                          cells: [

                            DataCell(
                               Text(market.instrument,style: TextStyle(color: _titleColor, fontWeight: FontWeight.bold, fontSize: 16)),


//                              Row(
//                                 children: <Widget>[
//                                   Expanded(
//
//                                       flex:2,
//                                       child:Text((count++).toString(),textAlign: TextAlign.left,)
//                                   ),
//                                   Expanded(
//                                       flex: 8,
//                                       child:
//                                   ),
//                                 ],
//                              )
                            ),
                            DataCell(
                              new Container(
                                child:     new Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(market.lastPrice.toString()),
                                    Text(market.volume24h.toString())
                                  ],
                                ),
                              )),
                            DataCell(
                                Text(market.volume24h.toString()),

                            )
                          ]
                      )
                  ).toList(),

                )
           // )
          ],
        );


    return
//      Container(
//      child:Column(
//          mainAxisSize: MainAxisSize.max,
//          children: <Widget>[
//            Container(
//              height: 50,
//              color: Theme.of(context).accentColor,
//              padding: EdgeInsets.all(10),
//              child:
//              Row(
//
//                children: <Widget>[
//                  Expanded(
//                      flex:2,
//                      child: Text("Coin")
//                  ),
//                  Expanded(
//                      flex:4,
//                      child: Text("Price")
//                  ),
//                  Expanded(
//                      flex:4,
//                      child: Text("Volume")
//                  )
//                ],
//              ),
//             ),

            RefreshIndicator(

                onRefresh: _onRefresh,
                child: listView,
            );

//          ],
//      )
//      );

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
        return Center(
          child: CircularProgressIndicator(),
        );

      },
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

}
