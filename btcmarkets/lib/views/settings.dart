import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:flutter/material.dart';

class SettingsView extends StatefulWidget {
  SettingsView();

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final TextEditingController _keyController = new TextEditingController();
  final TextEditingController _secretController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    var accentColor = Theme.of(context).accentColor;
    var hintColor = Theme.of(context).hintColor;
    var hintText = TextStyle(color: hintColor);
    var clearColor = Colors.red;
    
    var model = AppDataProvider.of(context).model;
    _keyController.text = model.settings.apiKey;
    _secretController.text = model.settings.secret;
    
    return new Scaffold(
        appBar: new AppBar(title: Text("Settings")),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
                flex: 9,
                child: ListView(
                  children: <Widget>[
                    ExpansionTile(
                      leading: Icon(Icons.vpn_key),
                      initiallyExpanded: true,
                      title: Text("Api Keys"),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text("Use", style: hintText),
                                          Padding(padding: EdgeInsets.symmetric(horizontal: 5),
                                          child: 
                                          Icon(Icons.filter_center_focus,
                                              size: 36, color: hintColor),
                                              ),
                                          Text("to scan text from QR code.",
                                              style: hintText)
                                        ],
                                      ),
                                      Text("Tap verify to test credentials.",
                                          style: hintText),
                                      SizedBox(height: 10),
                                      Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text("Api Key")),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                              child: TextField(
                                            autocorrect: false,
                                            controller: _keyController,
                                            maxLength: 100,
                                          
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12),
                                              border: OutlineInputBorder(),
                                              prefixIcon: IconButton(
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: clearColor,
                                                  ),
                                                  onPressed: () {
                                                    _keyController.clear();
                                                  }),
                                              suffixIcon: IconButton(
                                                  icon: Icon(
                                                    Icons.filter_center_focus,
                                                    size: 36,
                                                  ),
                                                  onPressed: () {}),
                                            ),
                                          )),
                                        ],
                                      )
                                    ],
                                  )),
                              SizedBox(height: 5),
                              Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                          padding:
                                              EdgeInsets.symmetric(vertical: 5),
                                          child: Text("Secret")),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                              child: TextField(
                                            autocorrect: false,
                                            controller: _secretController,
                                            maxLength: 100,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12),
                                              border: OutlineInputBorder(),
                                              prefixIcon: IconButton(
                                                  icon: Icon(Icons.clear,
                                                      color: clearColor),
                                                  onPressed: () {
                                                    _secretController.clear();
                                                  }),
                                              suffixIcon: IconButton(
                                                  icon: Icon(
                                                    Icons.filter_center_focus,
                                                    size: 36,
                                                  ),
                                                  onPressed: () {}),
                                            ),
                                          )),
                                        ],
                                      )
                                    ],
                                  )),
                              SizedBox(height: 5),
                              Align(
                                  alignment: Alignment.center,
                                  child: RaisedButton(
                                      child: Text("Verify"),
                                      color: accentColor,
                                      onPressed: () {})),
                              SizedBox(height: 5),
                            ],
                          ),
                        ),
                      ],
                    ),

                    Divider(height: 1),

                    //Divider(height:1),
                    Container(
                        padding: EdgeInsets.only(right: 20),
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                            child: ListTile(
                          leading: Icon(Icons.color_lens),
                          title: Text("Theme"),
                        )),
                        _getThemes()
                      ],
                    )),
                    Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(Icons.update),
                      title: Text("Live Updates"),
                      value: model.settings.liveUpdates,
                      onChanged: (bool newValue) {},
                      activeColor: accentColor,
                    ),
                    Divider(height: 1),
                    SwitchListTile(
                      secondary: Icon(Icons.notifications_active),
                      title: Text("Notifications"),
                      value: model.settings.notifications,
                      onChanged: (bool newValue) {},
                      activeColor: accentColor,
                    ),
                  ],
                )),

            
            Container(
              padding: EdgeInsets.symmetric(horizontal:10),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    child: Text("Save"),
                    color: primaryColor,
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget _getThemes() {
    var model = AppDataProvider.of(context).model;
    return DropdownButton<String>(
      items: [
        DropdownMenuItem(
            value: "Dark",
            child: Row(
              children: <Widget>[Text("Dark")],
            )),
        DropdownMenuItem(
            value: "Light",
            child: Row(
              children: <Widget>[Text("Light")],
            )),
      ],
      onChanged: (value) {
        setState((){  
          model.switchTheme(value);
        });
          
      },
      value: model.settings.theme,
    );
  }
}
