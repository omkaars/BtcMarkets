import '../viewmodels/appdatamodel.dart';
import 'package:flutter/material.dart';

class AppDataProvider extends InheritedWidget
{
  final AppDataModel model;
  final Widget child;

  const AppDataProvider({this.model, this.child}) : super(child: child);
  static AppDataProvider of(BuildContext context) =>
      context.inheritFromWidgetOfExactType(AppDataProvider);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
   
    return true;
  }

}