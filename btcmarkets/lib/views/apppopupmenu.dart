import 'package:btcmarkets/models/popupchoice.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/viewmodels/appdatamodel.dart';
import 'package:btcmarkets/views/settings.dart';
import 'package:flutter/material.dart';

import 'about.dart';

class AppPopupMenu extends StatefulWidget {
  AppPopupMenu();

  @override
  _AppPopupMenuState createState() => _AppPopupMenuState();
}

//ListTile.divideTiles(
class _AppPopupMenuState extends State<AppPopupMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<PopupChoice>(
      onSelected: (PopupChoice choice) {
        
        if(choice.title == "About")
        {
                 Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return AboutView();
        }));
        return;
        }
        else
        if(choice.title == "Lock")
        {
            var model = AppDataModel();
            model.lockApp();
            return;
        }
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return SettingsView();
        }));
      },
      icon: Icon(Icons.more_vert),
      itemBuilder: (BuildContext buildContext) {

        var model = AppDataModel();
        var choices = List<PopupChoice>();
        choices.add(
          new PopupChoice(title: "Settings", icon: Icons.settings));
        
        if(model.canLockApp)
        {
          choices.add(new PopupChoice(title: "Lock", icon: Icons.lock),
         );
        }
        choices.add(new PopupChoice(title: "About", icon: Icons.info));

        return choices.map((PopupChoice choice) {
          return PopupMenuItem<PopupChoice>(
              child: Text(choice.title), value: choice);
        }).toList();
      },
    );
  }
}
