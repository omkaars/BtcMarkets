import 'package:btcmarkets/providers/appdataprovider.dart';
import 'package:flutter/material.dart';

class SetPasswordView extends StatefulWidget {
  SetPasswordView();
  final TextEditingController password1Controller = new TextEditingController();
  final TextEditingController password2Controller = new TextEditingController();
  @override
  _SetPasswordViewState createState() => _SetPasswordViewState();
}

class _SetPasswordViewState extends State<SetPasswordView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
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

  @override
  Widget build(BuildContext context) {
    var hintColor = Theme.of(context).hintColor;
    var hintStyle = Theme.of(context).textTheme.subhead.copyWith(
          color: hintColor,
        );

    return new Scaffold(
        key: _scaffoldKey,
        body: Center(
            child: Stack(
          children: <Widget>[
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
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Set Password",
                                    style: hintStyle,
                                  )),
                              SizedBox(height: 5),
                              TextFormField(
                                controller: widget.password1Controller,
                                maxLength: 15,
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: "Enter password",
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () {
                                          widget.password1Controller.clear();
                                          _formKey.currentState.reset();
                                        }),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)))),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Password is required";
                                  }
                                   if(value.length<8)
                                  {
                                    return "Password must be atleast 8 characters";
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    "Confirm Password",
                                    style: hintStyle,
                                  )),
                              SizedBox(height: 5),
                              TextFormField(
                                controller: widget.password2Controller,
                                maxLength: 15,
                                
                                obscureText: true,
                                decoration: InputDecoration(
                                    hintText: "Reenter password",
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.cancel,
                                            color: Colors.red),
                                        onPressed: () {
                                          widget.password2Controller.clear();
                                          _formKey.currentState.reset();
                                        }),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)))),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Password is required";
                                  }
                                 
                                  if (value !=
                                      widget.password1Controller.text) {
                                    return "Confirm password must be same as Password";
                                  }
                                  return null;
                                },
                              )
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          RaisedButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              // checkPassword();
                              cancelTask();
                            },
                          ),
                          RaisedButton(
                            child: Text("Save"),
                            onPressed: () {
                              checkPassword();
                            },
                          )
                        ],
                      )
                    ]))
          ],
        )));
  }
}
