import 'package:btcmarkets/models/settings.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/views/setpassword.dart';
import 'package:flutter/material.dart';
import 'package:qr_reader/qr_reader.dart';

class SettingsView extends StatefulWidget {
  SettingsView();
  final TextEditingController keyController = new TextEditingController();
  final TextEditingController secretController = new TextEditingController();
  final ApiCredentials apiCredentials = ApiCredentials();
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  ApiCredentials _oldCredentials;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();

  }

  void showMessage(String message)
  {
     _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.green, content: Text(message)));
  }
  void showError(String error)
  {
    _scaffoldKey.currentState.showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(error)));
  }
  void readApiKey() async {
    var model = AppDataProvider.of(context).model;

    try {
      var qrReader = QRCodeReader();
      var apiKey = await qrReader.scan();

      widget.keyController.text = apiKey;
      model.apiCredentials.apiKey = apiKey;
    } catch (e) {
      model.showError("Cannot read QR code. Please provide apikey manually.");
    }
  }

  void readSecret() async {
    var model = AppDataProvider.of(context).model;

    try {
      var qrReader = QRCodeReader();

      var secret = await qrReader.scan();
      model.apiCredentials.secret = secret;

      widget.secretController.text = secret;
    } catch (e) {
      showError("Cannot read QR code. Please provide secret manually.");
    }
  }

  void save() async {
    print("In save");

    var model = AppDataProvider.of(context).model;

    var apiKey = model.apiCredentials.apiKey;
    var secret = model.apiCredentials.secret;

    var isValidData = apiKey != null &&
        apiKey.isNotEmpty &&
        secret != null &&
        secret.isNotEmpty &&
        apiKey.length >= 10 &&
        secret.length >= 10;
   // print("isValidData $isValidData");
    if (isValidData) {
     // print("checking auth....");
      var isValidAuth = await model.checkAuthentication(apiKey, secret);
      if (!isValidAuth) {
        showError("Invalid api credentails.");
        return;
      } else {
        print("Has Credentials changes ${model.hasCredentialsChanged}");
        print(model.currentCredentials.apiKey);
        print(model.currentCredentials.secret);
        if (model.hasCredentialsChanged) {

           var password = await Navigator.of(context).push(new MaterialPageRoute<String>(
        builder: (BuildContext context) {
          return new SetPasswordView();
        },
        fullscreenDialog: true));
          var result = await model.updateCredentials(password);
          if (!result) {
              showError("Something went wrong while updating credentials. Please try again");
            return;
          }

          showMessage("Saved settings successfully");
        }
      }
    }

    await model.saveSettings();
    // model.showMessage("Saved settings successfully.");
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    var accentColor = Theme.of(context).accentColor;
    var hintColor = Theme.of(context).hintColor;
    var hintText = TextStyle(color: hintColor);
    var clearColor = Colors.red;

   // print("building settings agains");
    var model = AppDataProvider.of(context).model;

    widget.keyController.text = model.apiCredentials.apiKey;
    widget.secretController.text = model.apiCredentials.secret;
  
    return new Scaffold(
        key: _scaffoldKey,
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
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 5),
                                            child: Icon(
                                                Icons.filter_center_focus,
                                                size: 36,
                                                color: hintColor),
                                          ),
                                          Text("to scan text from QR code.",
                                              style: hintText)
                                        ],
                                      ),
                                     
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
                                            controller: widget.keyController,
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
                                                    widget.keyController
                                                        .clear();
                                                  }),
                                              suffixIcon: IconButton(
                                                  icon: Icon(
                                                    Icons.filter_center_focus,
                                                    size: 36,
                                                  ),
                                                  onPressed: () {
                                                    readApiKey();
                                                  }),
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
                                            controller: widget.secretController,
                                            maxLength: 100,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12),
                                              border: OutlineInputBorder(),
                                              prefixIcon: IconButton(
                                                  icon: Icon(Icons.clear,
                                                      color: clearColor),
                                                  onPressed: () {
                                                    widget.secretController
                                                        .clear();
                                                  }),
                                              suffixIcon: IconButton(
                                                  icon: Icon(
                                                    Icons.filter_center_focus,
                                                    size: 36,
                                                  ),
                                                  onPressed: () {
                                                    readSecret();
                                                  }),
                                            ),
                                          )),
                                        ],
                                      )
                                    ],
                                  )),
                              SizedBox(height: 5),
                              // Align(
                              //     alignment: Alignment.center,
                              //     child: RaisedButton(
                              //         child: Text("Verify"),
                              //         color: accentColor,
                              //         onPressed: () {})),
                              // SizedBox(height: 5),
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
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  RaisedButton(
                    child: Text("Save"),
                    color: primaryColor,
                    onPressed: () {
                      save();
                    },
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
        setState(() {
          model.switchTheme(value);
        });
      },
      value: model.settings.theme,
    );
  }
}
