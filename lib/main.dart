import 'package:controlly/homeassistant/homeassistant.dart';
import 'package:controlly/settings/model.dart';
import 'package:controlly/settings/view.dart';
import 'package:controlly/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:controlly/widgets/sensor.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Controlly',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ControllyHome(title: 'Controlly'),
    );
  }
}

class ControllyHome extends StatefulWidget {
  const ControllyHome({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<ControllyHome> createState() => _ControllyHomeState();
}

/// This is the deepest widget that has state
/// in this widget, we wait for the data store to load,
/// and then render the widget tree accordingly
class _ControllyHomeState extends State<ControllyHome> {
  Future launch(BuildContext context, Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    refresh();
  }

  @override
  void initState() {
    // store.ha.updates.listen()
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    checkSettings();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void checkSettings() async {
    await settingsManager.ready;
    if (settingsManager.getItem('haHost')?.isNotEmpty) {
      // attempt to connect
      store.ha?.destroy();
      store.ha = HomeAssistant(HomeAssistantSettings(
        ip: settingsManager.getItem('haHost'),
        port: int.tryParse(settingsManager.getItem('haPort')) ?? 8123,
        ssl: settingsManager.getItem('haSSL'),
        longLivedToken: settingsManager.getItem('haToken'),
      ));
      await store.ha!.connect();
      refresh();
    }
  }

  void haUpdateHandler() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => launch(context, const SettingsPage()),
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: settingsManager.ready,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          } else if (store.ha == null || !store.ha!.connected) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Click settings button for settings',
                  ),
                  IconButton(
                    iconSize: 60,
                    icon: const Icon(
                      Icons.settings,
                    ),
                    onPressed: () => launch(context, const SettingsPage()),
                  ),
                ],
              ),
            );
          } else {
            /// here we have a home assistant instance
            return StreamBuilder(
              stream: store.ha!.updates,
              builder: (context, snapshot) {
                return Stack(
                  children: [
                    // background image
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: Image.network(
                        'https://images.pexels.com/photos/2365457/pexels-photo-2365457.jpeg?auto=compress&cs=tinysrgb&dpr=3&h=750&w=1260',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // scrollable widget area
                    Positioned(
                      left: 24,
                      top: 0,
                      bottom: 0,
                      right: 0,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (var entity in store.ha!.entities) SensorWidget(entity: entity),
                            /* Container(
                                width: 200,
                                height: 100,
                                color: Colors.blue,
                                child: ListView(
                                  children: [
                                    Icon(entity.isOn ? Icons.lightbulb : Icons.lightbulb_outline),
                                    Text(entity.name),
                                    for (var key in entity.attributes.keys)
                                      Column(
                                        children: [
                                          Text(key + ':'),
                                          Text(entity.attributes[key].toString()),
                                          const SizedBox(height: 10),
                                        ],
                                      )
                                  ],
                                ),
                              ) */
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: buildBottomBarItems(),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  List<BottomNavigationBarItem> buildBottomBarItems() {
    // This list will eventually be pulled from the UI config file
    // once that is ready
    const items = {
      'home': {
        'icon': 'home',
        'title': 'Home',
      },
      'lighting': {
        'icon': 'lightbulb',
        'title': 'Lighting',
      },
      'climate': {
        'icon': 'thermometer',
        'title': 'Climate',
      },
      'maintenance': {
        'icon': 'wrench',
        'title': 'Maintenance',
      },
    };

    var navBarItems = <BottomNavigationBarItem>[];

    items.forEach((key, value) {
      navBarItems.add(BottomNavigationBarItem(
        icon: Icon(MdiIcons.fromString(value['icon'] ?? 'folder')),
        label: value['title'],
      ));
    });

    return navBarItems;
  }
}
