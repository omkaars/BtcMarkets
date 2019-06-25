enum AppTheme { dark, light }

class ApiCredentials {
  ApiCredentials({this.apiKey, this.secret});
  String apiKey;
  String secret;


  ApiCredentials.fromJson(json)
      : apiKey = json["apiKey"],
        secret = json["secret"];

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'secret': secret,
    };
  }

  bool get isValid => apiKey != null && secret != null && apiKey.isNotEmpty && secret.isNotEmpty; 
}

class Settings {

  Settings({this.credentials, this.liveUpdates, this.notifications, this.theme});
  
  String credentials;

  bool liveUpdates = true;
  bool notifications = true;

  String theme = "Dark";

  Settings.fromJson(json) {
    try {
      
      credentials = json["credentials"];
      liveUpdates = json["liveUpdates"];
      notifications = json["notifications"];

      theme = json["theme"];
    } catch (e) {}
  }

  Map<String, dynamic> toJson() {
    return {
      "credentials": credentials,
      "liveUpdates": liveUpdates,
      "notifications": notifications,
      "theme": theme
    };
  }
}
