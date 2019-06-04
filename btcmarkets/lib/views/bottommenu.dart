import 'package:flutter/material.dart';


class BottomMenu extends StatefulWidget {

  final int defaultIndex;
  BottomMenu({Key key, @required this.defaultIndex}): super(key:key);

  @override
  _BottomMenuState createState() => _BottomMenuState();

}

//ListTile.divideTiles(
class _BottomMenuState extends State<BottomMenu>
{

  void _onItemTapped(int index) {
    setState(() {
      String routeName = "/";
      switch(index)
      {
        case 1:
            routeName = "/markets";
      }
      Navigator.pushNamed(context, routeName);
    });
  }

  @override
  Widget build(BuildContext context) {

    return new  BottomNavigationBar(
      showUnselectedLabels: true,
      showSelectedLabels: true,
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
        BottomNavigationBarItem(
          icon: Icon(Icons.linear_scale),
          title: Text('More'),
        ),
      ],
      currentIndex: widget.defaultIndex,
      selectedItemColor: Theme.of(context).accentColor,
      onTap: _onItemTapped,
    );
  }
}