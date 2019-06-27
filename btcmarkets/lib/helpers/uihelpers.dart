import 'package:btcmarkets/models/appmessage.dart';
import 'package:flutter/material.dart';

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}


class ViewHelper{
  static final ViewHelper _view = new ViewHelper._internal();
    
    factory ViewHelper() {
      return _view;
    }
  
    ViewHelper._internal(){
    
    }
    BuildContext _context;
    void setContext(BuildContext context)
    {
      _context = context;
    }

  Future<T> showPopup<T>(Widget content,{String title, bool isModal}) async
  {
     var context = _context;
       var result = await showGeneralDialog<T>(
          context: context,
            barrierColor: Colors.black54.withOpacity(0.5),
          barrierDismissible: !(isModal??false),
          barrierLabel: "", 
          transitionDuration: Duration(milliseconds: 200),                 
          pageBuilder: (BuildContext buildContext, Animation animation1, Animation animation2){ },
          transitionBuilder : (BuildContext buildContext, Animation animation1, Animation animation2, Widget element) {
            return Transform.scale(
              
              scale: animation1.value,

              child: Opacity(opacity: animation1.value,
              child:
              
              AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 10,
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: EdgeInsets.zero,
                child:Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   mainAxisSize: MainAxisSize.min,
                  children:[
                    
                    Container(
                      padding: EdgeInsets.all(10),
                      
                      decoration: BoxDecoration(
                        color:Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                      child:Text(title,)),

                      content
                 
                  ]

                )
              ),
            )
            )
            );
            
          });

    //  var result = await showDialog<T>(
    //       context: context,
          
    //       builder: (BuildContext buildContext) {
    //         return AlertDialog(
            
    //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    //           elevation: 10,
    //           contentPadding: EdgeInsets.zero,
    //           content: content
    //         );
            
    //       });
      return result;          
  }

  void showMessage(AppMessage appMessage) {
    try {
      String title;
      Color color;
      switch (appMessage.messageType) {
        case MessageType.success:
          title = "Success";
          color = Colors.green;
          break;

        case MessageType.error:
          title = "Error";
          color = Colors.red;
          break;
        case MessageType.warning:
          title = "Info";
          color = Colors.grey;
          break;
      }

      var context = _context;

      
      showGeneralDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.5),
          barrierDismissible: !(appMessage.isModal??false),
          barrierLabel: "", 
          transitionDuration: Duration(milliseconds: 200),                 
          pageBuilder: (BuildContext buildContext, Animation animation1, Animation animation2){ },
          transitionBuilder : (BuildContext buildContext, Animation animation1, Animation animation2, Widget element) {
            return Transform.scale(
              
              scale: animation1.value,

              child: Opacity(opacity: animation1.value,
              child:
              
              AlertDialog(
             
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              elevation: 10,
              contentPadding: EdgeInsets.zero,
              content: Container(
                padding: EdgeInsets.zero,
                child:Column(
                   crossAxisAlignment: CrossAxisAlignment.stretch,
                   mainAxisSize: MainAxisSize.min,
                  children:[
                    
                    Container(
                        padding: EdgeInsets.all(10),
                      
                      decoration: BoxDecoration(
                        color:color,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0))),
                      child:Text(title,)),

                  
                    Container(
                      padding: EdgeInsets.all(10),
                      child:Text(appMessage.message)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                      RaisedButton(child: Text("Ok"), onPressed: (){
                    Navigator.of(context).pop();
                  },
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                   )
                  ],)
                  ]

                )
              ),
            )
            )
            );
            
          });
    } catch (e) {

      print(e);
    }
  }
}

