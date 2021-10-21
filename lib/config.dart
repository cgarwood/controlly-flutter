/// an easy way to have persistent configuration data is to create one class
/// with all the data in it, create one instance of that class
/// and then import this file wherever you need to use that class since
/// Dart will only instantiate the class the first time the file is imported
/// the same technique also works for globally available state data
///
/// HOWEVER, another way is to create a Class with static const variables only
/// And access it from the parent class [Config.hassClientId]

class Config {
  static const hassClientId = "https://jeffmikels.org/controlly.html";
  static const hassRedirectUri = "controlly://main/hass";
}
