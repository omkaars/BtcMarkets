import 'dart:async';
import 'dart:io';

// import 'package:appcenter/appcenter.dart';
// import 'package:appcenter_analytics/appcenter_analytics.dart';
// import 'package:appcenter_crashes/appcenter_crashes.dart';
import 'package:btcmarkets/models/appmessage.dart';
import 'package:btcmarkets/models/navview.dart';
import 'package:btcmarkets/views/password.dart';
import 'package:btcmarkets/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/semantics.dart';
import '../helpers/uihelpers.dart';

import 'about.dart';
import 'home.dart';
import 'markets.dart';
import 'more.dart';
import 'news.dart';
import 'trades.dart';
import 'account.dart';
import '../providers/appdataprovider.dart';
import '../viewmodels/appdatamodel.dart';
import 'password.dart';

class CustomPopupMenu {
  CustomPopupMenu({this.title, this.icon});

  String title;
  IconData icon;
}

class BtcMarketsApp extends StatefulWidget {
  BtcMarketsApp()
  {
   // initAppCenter();
  }

// void initAppCenter() async {
//   print("Initialising app center");
  
//   var appSecret = Platform.isIOS ? "5d6b2da9-493f-403b-8831-1ba0a7bbf457" : "6c97d9a4-5334-4670-856d-e3e7c186b8f1";
//   await AppCenter.start(
//       appSecret, [AppCenterAnalytics.id, AppCenterCrashes.id]);
// }

  @override
  _BtcMarketsAppState createState() => _BtcMarketsAppState();
}

class _BtcMarketsAppState extends State<BtcMarketsApp> {
  _BtcMarketsAppState();

  static Color primaryColor = HexColor("#3C6B3C");
  static Color accentColor = HexColor("#ff9933");

  final darkTheme = ThemeData.dark().copyWith(
      primaryColor: primaryColor,
      accentColor: accentColor,
      indicatorColor: accentColor);
  final lightTheme = ThemeData.light().copyWith(
    primaryColor: primaryColor,
    accentColor: accentColor,
    indicatorColor: accentColor,
  );

  ThemeData _theme;
  AppDataModel _model;

  @override
  Widget build(BuildContext context) {
    if (_model == null) {
      _model = AppDataModel();
    
     
    }
    return AppDataProvider(
        model: _model,
        child: StreamBuilder(
          stream: _model.settingsStream,
          builder: (BuildContext buildContext, AsyncSnapshot<String> snapshot) {
            switch (_model.settings.theme) {
              case "Light":
                _theme = lightTheme;
                break;
              default:
                _theme = darkTheme;
                break;
            }
            Widget homeScreen;
            if(_model.passwordRequired)
            {
              homeScreen = PasswordView();
            }
            else
            {
             homeScreen = BottomMenuController();
            }
            return MaterialApp(
                title: 'BTC Markets',
                theme: _theme,
                home: homeScreen,
                routes: <String, WidgetBuilder>{});
          },
        ));
  }
}

class BottomMenuController extends StatefulWidget {
  @override
  _BottomMenuControllerState createState() => _BottomMenuControllerState();
}

class _BottomMenuControllerState extends State<BottomMenuController> {
  final List<Widget> pages = [
    HomeView(),
    MarketsView(),
    TradesView(),
    AccountView(),
    NewsView()
  ];

  final PageStorageBucket bucket = PageStorageBucket();

  int _selectedIndex = 0;
  StreamSubscription<NavView> _navViewStream;
  Widget _bottomNavigationBar(int selectedIndex) => BottomNavigationBar(
        onTap: (int index) => setState(() {
              var model = AppDataProvider.of(context).model;

              if (index == 3) {
                if (!model.isValidAccount) {
                  
              
                  _selectedIndex = 0;
                  Scaffold.of(_scaffold).showSnackBar(SnackBar(backgroundColor: Colors.red,
                    content: Text(
                        "Account feature not available. You must setup valid apikey and secret in settings."),
                    duration: Duration(seconds: 3),
                  ));
                  return;
                }
              }
              
              _selectedIndex = index;
            }),
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

  StreamSubscription _pageLoadingSub, _messageSub;

  void _initListeners() {
    var model = AppDataProvider.of(context).model;

    if (_pageLoadingSub != null) {
      _pageLoadingSub.cancel();
    }
    _pageLoadingSub = model.pageLoadingStream.listen((loading) {
      setState(() {
        _loading = loading;
      });
    });

    if (_messageSub != null) {
      _messageSub.cancel();
    }
    _messageSub = model.messageNotifierStream.listen((appMessage) {
      if (_scaffold != null) {
        var color = Colors.green;
        if(appMessage.messageType == MessageType.error)
        {
          color = Colors.red;
        }
        Scaffold.of(_scaffold).showSnackBar(SnackBar(
            backgroundColor: color,
            content: Text(appMessage.message),
            duration: Duration(seconds: 3)));
      }
    });

    if (_navViewStream != null) {
      _navViewStream.cancel();
    }
    _navViewStream = model.navStream.listen((nav) {
      setState(() {
        var model = AppDataProvider.of(context).model;

        switch (model.view.view) {
          case View.Home:
            _selectedIndex = 0;
            break;
          case View.Markets:
            _selectedIndex = 1;
            break;
          case View.Trades:
            _selectedIndex = 2;
            break;
          case View.Account:
           // print('valid Account **************');
            if (model.isValidAccount) {
             // print('valid Account **************');
              _selectedIndex = 3;
            } else {
              _selectedIndex = 0;
              Scaffold.of(_scaffold).showSnackBar(SnackBar(
                content: Text(
                    "Not available. You must setup apikey and secret in settings"),
                duration: Duration(seconds: 3),
              ));
            }
            break;
          case View.News:
            _selectedIndex = 4;
            break;
          case View.Settings:
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return SettingsView();
            }));
            break;
          case View.About:
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext buildContext) {
              return AboutView();
            }));
            break;
          default:
            _selectedIndex = 0;
            break;
        }
      });
    });
  }

  bool _loading = false;
  BuildContext _scaffold;
  @override
  Widget build(BuildContext context) {
    _initListeners();

    var scaffold = Scaffold(
        bottomNavigationBar: _bottomNavigationBar(_selectedIndex),
        body: Builder(
          builder: (scaffoldContext) {
            _scaffold = scaffoldContext;
            return pages[_selectedIndex];
          },
        )
        // )
        );

    return Stack(children: [
      scaffold,
      Opacity(
        opacity: _loading ? 1.0 : 0.0,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ]);
  }

  @override
  void dispose() {
    super.dispose();
    var model = AppDataProvider.of(context).model;
    if (_navViewStream != null) {
      _navViewStream.cancel();
    }
    if (_pageLoadingSub != null) {
      _pageLoadingSub.cancel();
    }
    if (_messageSub != null) {
      _messageSub.cancel();
    }
  }
}
