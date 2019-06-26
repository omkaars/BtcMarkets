import 'package:btcmarkets/models/appmessage.dart';
import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:btcmarkets/views/setpassword.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/status.dart';

class PasswordView extends StatefulWidget {
  PasswordView();
  final TextEditingController passwordController = new TextEditingController();
  final FocusNode focusNode = new FocusNode();
  @override
  _PasswordViewState createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();

  void checkPassword() async {
    // _showDialog();
    // var result = await Navigator.of(context).push(new MaterialPageRoute<String>(
    //     builder: (BuildContext context) {
    //       return new SetPasswordView();
    //     },
    //     fullscreenDialog: true));

    if (_formKey.currentState.validate()) {
      var password = widget.passwordController.text;
      var model = AppDataProvider.of(context).model;

      var result = await model.loadCredentials(password);
    
      if (result) {
       // model.passwordRequired = false;
        model.refreshApp();
      } else {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("Invalid password. Please try again."),
        ));

       // AppDataProvider.of(_scaffoldKey.currentContext).showMessage(AppMessage(message:"Invalid password. Please try again.", messageType: MessageType.error));
      }
    }
  }

  void resetLock()
  {
    clearPassword();
    var model = AppDataProvider.of(context).model;
    model.resetCredentails();
    model.refreshApp();
  }

  void clearPassword()
  {
    widget.focusNode.unfocus();
    widget.passwordController.clear();
    
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        body: Center(
            child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Enter password to unlock"),
                      SizedBox(
                        height: 10,
                      ),
                      Form(
                          key: _formKey,
                          child: TextFormField(
                            maxLength: 15,
                            controller: widget.passwordController,
                            focusNode: widget.focusNode,
                            obscureText: true,
                            initialValue:null,
                            decoration: InputDecoration(
                                contentPadding:
                                                  EdgeInsets.all(12),
                                hintText: "Enter password",
                                suffixIcon: IconButton(
                                    icon: Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      widget.passwordController.clear();
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

                              return null;
                            },
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                      
                      RaisedButton(
                        color: Colors.red,
                        child: Text("Reset Lock"),
                        onPressed: () {
                         resetLock();
                        },
                      ),
                      RaisedButton(
                        color: Theme.of(context).primaryColor,
                        child: Text("Unlock"),
                        onPressed: () {
                          
                           checkPassword();
                        },
                      )


                      ],)
                    ]))));
  }
}
