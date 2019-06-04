import 'dart:async';
import 'package:flutter/material.dart';

class SplashView extends StatefulWidget
{
  @override
  State<StatefulWidget> createState() => new _SplashState();
}

class _SplashState extends State<SplashView> {

  _SplashState();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future _init() async {


    String route;
 //   if (_authManager.loggedIn) {
      route = '/home';
 //   } else {
   //   route = '/login';
    //}
    await Future.delayed(const Duration(seconds: 1), () => "5");

    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        body: new Center(
            child: new CircularProgressIndicator()
        )
    );
  }
}