// lib/settings_model.dart

class Settings {
  bool firstOpen;
  String cur;
  String lang;

  Settings(this.firstOpen, this.cur, this.lang);

  Map<String, dynamic> toJson() {
    return {
      'firstOpen': firstOpen,
      'cur': cur,
      'lang': lang,
    };
  }
}