import 'package:flutter/material.dart';

class NavDrawer extends StatefulWidget {
  NavDrawer();



  @override
  _NavDrawerState createState() => _NavDrawerState();

}

//ListTile.divideTiles(
class _NavDrawerState extends State<NavDrawer>
{

  final bool hasValidAccount = false;

  void _onSelectMenu(String name)
  {
    switch(name)
    {
      case "home":

      break;
    }
    
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return new Drawer(
        child: new ListView(
            padding: EdgeInsets.zero,
            children:
             <Widget>[
               new Container(
                height: 150,
                child: new DrawerHeader(
                  child: new Text("DRAWER HEADER.."),
                  decoration: new BoxDecoration(
                      color: Theme.of(context).accentColor
                  ),
                 // margin: EdgeInsets.all(0.0),
                  //padding: EdgeInsets.all(0.0),
                ),
                ),
                ListTile(leading: Icon(Icons.home), title: Text('Home'), onTap: ()=> _onSelectMenu("home"), ),
                new Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.swap_vert), title: Text('Markets')),
           
              //   ListTile(
              //       leading: Icon(Icons.favorite), title: Text('Favourites'), trailing: Icon(Icons.arrow_forward_ios),),
              //  new Divider(height: 1),
              //   ListTile(
              //       leading: Icon(Icons.show_chart), title: Text('BTC Markets'), trailing: Icon(Icons.arrow_forward_ios),),
              //  new Divider(height: 1),
              //   ListTile(
              //     leading: Icon(Icons.show_chart), title: Text('AUD Markets'), trailing: Icon(Icons.arrow_forward_ios),),
              //  new Divider(height: 1),
              //   ListTile(
              //       leading: Icon(Icons.swap_vert), title: Text('Market Trades'), trailing: Icon(Icons.arrow_forward_ios),),
               new Divider(height: 1),
                ListTile(
                    leading: Icon(Icons.attach_money), title: Text('Balances'), enabled: hasValidAccount),
               new Divider(height: 1),
                ListTile(leading: Icon(Icons.format_list_bulleted),
                    title: Text('Open Orders'), enabled: hasValidAccount),
               new Divider(height: 1),
                ListTile(leading: Icon(Icons.view_list),
                    title: Text('Orders History'), enabled: hasValidAccount),
               new Divider(height: 1),
                ListTile(leading: Icon(Icons.monetization_on),
                    title: Text('Funds History'), enabled: hasValidAccount),
               new Divider(height: 1),
                ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
               new Divider(height: 1),
                ListTile(leading: Icon(Icons.view_list), title: Text('News')),
               new Divider(height: 1),
                ListTile(leading: Icon(Icons.info), title: Text('About')),
               new Divider(height: 1),
              ],

        ) //end listview
    ); //end Drawar
  }
}