


import 'package:flutter/material.dart';
import '../helpers/uihelpers.dart';

import 'home.dart';
import 'markets.dart';
import 'more.dart';
import 'news.dart';
import 'trades.dart';
import 'account.dart';
import '../providers/appdataprovider.dart';
import '../viewmodels/appdatamodel.dart';

class CustomPopupMenu {
  CustomPopupMenu({this.title, this.icon});

  String title;
  IconData icon;
}

class BtcMarketsApp extends StatelessWidget
{
    BtcMarketsApp();

   static Color primaryColor = HexColor("#3C6B3C");
   static Color accentColor = HexColor("#ff9933");

   final darkTheme = ThemeData.dark().copyWith(
     primaryColor: primaryColor,
     accentColor: accentColor,
     indicatorColor: accentColor
   );
   final lightTheme = ThemeData.light().copyWith(
     primaryColor: primaryColor,
     accentColor: accentColor,
     indicatorColor: accentColor,
   );



    @override
   Widget build(BuildContext context) {

     return
       AppDataProvider(
         model: AppDataModel(),
      child:
       MaterialApp(
       title: 'BTC Markets',
       theme: lightTheme,
        home: BottomMenuController(),
       routes: <String, WidgetBuilder>{

//            "/settings": (BuildContext context) => new SettingsView()

       },

       //onGenerateRoute: router.generator,
       )
     );
   }

}


class BottomMenuController extends StatefulWidget
{

  @override
  _BottomMenuControllerState createState() =>
      _BottomMenuControllerState();
}

class _BottomMenuControllerState
    extends State<BottomMenuController>
{

  final List<Widget> pages = [
      HomeView(),
    MarketsView(),
    TradesView(),
    AccountView(),
    NewsView()
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 0;

  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(

    onTap: (int index) => setState(() => _selectedIndex = index),
    currentIndex: selectedIndex,
    type: BottomNavigationBarType.fixed,
    items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text('Home'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.show_chart),
        title: Text('Markets'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.swap_vert),
        title: Text('Trades'),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_box),
        title: Text('Account'),
      ),

      BottomNavigationBarItem(
        icon: Icon(Icons.view_list),
        title: Text('News'),
      ),
    ],

    selectedItemColor: Theme.of(context).accentColor,

  );

  @override
  Widget build(BuildContext context) {

    return
                 Scaffold(
                bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
                body: pages[_selectedIndex]
             // )
            );
  }
}