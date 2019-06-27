import 'package:btcmarkets/helpers/uihelpers.dart';
import 'package:btcmarkets/models/appmessage.dart';
import 'package:btcmarkets/models/settings.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/viewmodels/appdatamodel.dart';
import 'package:btcmarkets/views/setpassword.dart';
import 'package:flutter/material.dart';
import 'package:qr_reader/qr_reader.dart';

class SettingsView extends StatefulWidget {
  SettingsView();
  final TextEditingController keyController = new TextEditingController();
  final TextEditingController secretController = new TextEditingController();
  final TextEditingController password1Controller = new TextEditingController();
  final TextEditingController password2Controller = new TextEditingController();

  final FocusNode keyFocus = FocusNode();
  final FocusNode secretFocus = FocusNode();

  final ApiCredentials apiCredentials = ApiCredentials();
  final PasswordData passwordData = PasswordData();

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class PasswordData {
  String password;
  String confirmPassword;
}

class _SettingsViewState extends State<SettingsView> {
  ApiCredentials _oldCredentials;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    widget.keyController.addListener(this.setApiKey);
    widget.secretController.addListener(this.setSecret);

    widget.password1Controller.addListener(this.setPassword);
    widget.password2Controller.addListener(this.setConfirmPassword);
  }

  void showMessage(String message) {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(backgroundColor: Colors.green, content: Text(message)));
  }

  void showError(String error) {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text(error)));
  }

  void clearApiKey() {
    widget.keyController.clear();
    var model = AppDataModel();
    model.apiCredentials.apiKey = widget.keyController.text;
  }

  void clearSecret() {
    widget.secretController.clear();
    var model = AppDataModel();
    model.apiCredentials.secret = widget.secretController.text;
  }

  void readApiKey() async {
    var model = AppDataModel();

    try {
      var qrReader = QRCodeReader();
      var apiKey = await qrReader.scan();

      if(apiKey == null || apiKey.isEmpty || apiKey.length<=15)
      return;
      
      widget.keyController.text = apiKey;
      model.apiCredentials.apiKey = apiKey;
    } catch (e) {
      model.showError("Cannot read QR code. Please provide apikey manually.");
    }
  }

  void readSecret() async {
    var model = AppDataModel();

    try {
      var qrReader = QRCodeReader();

      var secret = await qrReader.scan();
      if(secret == null || secret.isEmpty || secret.length<=15)
      return;

      model.apiCredentials.secret = secret;

      widget.secretController.text = secret;
    } catch (e) {
      showError("Cannot read QR code. Please provide secret manually.");
    }
  }

  void setApiKey() {
    var model = AppDataModel();

    var key = widget.keyController.text;
    //print("key editing completed $key");
    model.apiCredentials.apiKey = key;
  }

  void setSecret() {
    var model = AppDataModel();

    var secret = widget.secretController.text;
    //print("secret editing completed $secret");
    model.apiCredentials.secret = secret;
  }

  void setPassword() {
    var pass = widget.password1Controller.text;
    widget.passwordData.password = pass;
    //print("password changed $pass");
  }

  void setConfirmPassword() {
    var pass = widget.password2Controller.text;
    widget.passwordData.confirmPassword = pass;
    //print("Conform password changed $pass");
  }

  final _formKey = GlobalKey<FormState>();

  void cancelTask() {
    Navigator.of(context).pop();
  }

  void checkPassword() async {
    if (_formKey.currentState.validate()) {
      var password = widget.password1Controller.text;

      Navigator.of(context).pop(password);
    }
  }

  void save() async {
   // print("In save");

    widget.keyFocus.unfocus();
    widget.secretFocus.unfocus();
    widget.passwordData.password = null;
    widget.passwordData.confirmPassword = null;

    var model = AppDataModel();
    var apiKey = model.apiCredentials.apiKey;
    var secret = model.apiCredentials.secret;

   // print("In Save Api Key $apiKey Secret $secret");

    var isValidData = apiKey != null &&
        apiKey.isNotEmpty &&
        secret != null &&
        secret.isNotEmpty &&
        apiKey.length >= 10 &&
        secret.length >= 10;

    var currentCredentials = model.currentCredentials;
    var isSame = currentCredentials.apiKey != null &&
        currentCredentials.secret != null &&
        currentCredentials.apiKey == apiKey &&
        currentCredentials.secret == secret;

    //print("in save areValida $isValidData and are same $isSame");

    if (!isSame) {
      //print("checking auth....");

      if (isValidData) {
        var isValidAuth = await model.checkAuthentication(apiKey, secret);
        if (!isValidAuth) {
          showError("Invalid api credentails.");
          return;
        } else {
          //print("Has Credentials changes ${model.hasCredentialsChanged}");
          //print(model.currentCredentials.apiKey);
          //print(model.currentCredentials.secret);
          if (model.hasCredentialsChanged) {
            await  ViewHelper().showPopup<String>(_getSetPassword(), title: "Set Password",isModal: true);
            var password = widget.passwordData.password;
            //print("in Save got password $password");
            if (password == null || password.isEmpty) {
              print("No password provided, skipping updating");
              return;
            }
            var result = await model.updateCredentials(password);
            if (!result) {
              showError(
                  "Something went wrong while updating credentials. Please try again");
              return;
            }

            //showMessage("Saved settings successfully");
          }
        }
      }
      else
      {
          if(model.currentCredentials.isValid)
          {
           //   print("Resetting credentials");
              model.resetCredentails();
              
              model.refreshMarkets();
          }
      }
    }

    await model.saveSettings();
     ViewHelper().showMessage(AppMessage(
        message: "Saved settings successfully.",
        messageType: MessageType.success,
        isModal: true));
  }

  @override
  Widget build(BuildContext context) {
    var primaryColor = Theme.of(context).primaryColor;
    var accentColor = Theme.of(context).accentColor;
    var hintColor = Theme.of(context).hintColor;
    var hintText = TextStyle(color: hintColor);
    var clearColor = Colors.red;

    // print("building settings agains");
    var model = AppDataModel();

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
                                            focusNode: widget.keyFocus,
                                            maxLength: 100,
                                            onChanged: (value) {
                                              print("Changed apikey $value");
                                              model.apiCredentials.apiKey =
                                                  value;
                                            },
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
                                                    clearApiKey();
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
                                            focusNode: widget.secretFocus,
                                            onChanged: (value) {
                                           //   print("Changed secret $value");
                                              model.apiCredentials.secret =
                                                  value;
                                            },
                                            maxLength: 100,
                                            decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(12),
                                              border: OutlineInputBorder(),
                                              prefixIcon: IconButton(
                                                  icon: Icon(Icons.clear,
                                                      color: clearColor),
                                                  onPressed: () {
                                                    clearSecret();
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
    var model = AppDataModel();
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

  Widget _getSetPassword() {
    var primaryColor = Theme.of(context).primaryColor;
    var accentColor = Theme.of(context).accentColor;

    var hintColor = Theme.of(context).hintColor;
    var hintStyle = Theme.of(context).textTheme.subhead.copyWith(
          color: hintColor,
        );

    return 
    SingleChildScrollView(child:
    Container(
        padding: EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      // Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Text(
                      //       "Set Password",
                      //       style: hintStyle,
                      //     )),
                      // SizedBox(height: 5),
                      TextFormField(
                        controller: widget.password1Controller,
                        maxLength: 15,
                        obscureText: true,
                        initialValue: widget.passwordData.password,
                        decoration: InputDecoration(
                           contentPadding:
                                                  EdgeInsets.all(12),
                            hintText: "Enter password",
                            suffixIcon: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  widget.password1Controller.clear();
                                  _formKey.currentState.reset();
                                }),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)))),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Password is required";
                          }
                          if (value.length < 8) {
                            return "Password must be atleast 8 characters";
                          }
                          widget.passwordData.password = value;
                          return null;
                        },
                      ),
                    
                      // Align(
                      //     alignment: Alignment.topLeft,
                      //     child: Text(
                      //       "Confirm Password",
                      //       style: hintStyle,
                      //     )),
                      SizedBox(height: 5,),
                      Wrap(children: <Widget>[
                      TextFormField(
                        controller: widget.password2Controller,
                        maxLength: 15,
                        initialValue: widget.passwordData.confirmPassword,
                        obscureText: true,
                        decoration: InputDecoration(
                             contentPadding:
                                                  EdgeInsets.all(12),
                            hintText: "Confirm password",
                            suffixIcon: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  widget.password2Controller.clear();
                                  _formKey.currentState.reset();
                                }),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)))),
                        validator: (value) {
                          if (value.isEmpty) {
                            return "Password is required";
                          }
                          //print(
                            //  "Checking same ,$value, ${widget.passwordData.password} ,");
                          if (value != widget.passwordData.password) {
                            return "Confirm password must be same as Password";
                          }
                          widget.passwordData.confirmPassword = value;
                          return null;
                        },
                      )
                      ],)
                    ],
                  )),
             
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  
                  RaisedButton(
                    color:accentColor,
                    child: Text("Cancel"),
                    onPressed: () {
                      // checkPassword();
                      cancelTask();
                    },
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  ),
                  RaisedButton(
                    child: Text("Save"),
                    color: accentColor,
                    onPressed: () {
                      checkPassword();
                    },
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  )
                ],
              )
            ]))
            );
  }
}
