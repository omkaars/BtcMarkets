enum MessageType
{
  success,
  error,
  warning 
}

class AppMessage{
  
  AppMessage({this.message, this.messageType, this.isModal});
  MessageType messageType;
  String message;
  bool isModal;
  
}