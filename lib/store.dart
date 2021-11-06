import './homeassistant/homeassistant.dart';
// import './snapcast/snapcast.dart';

class Store {
  HomeAssistant? ha;
  // late Snapcast sc;

  Map userConfig = {};

  Map device = {};

  Store();
}

Store store = Store();
