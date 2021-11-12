import 'dart:async';
import 'dart:developer' as developer;

import 'package:controlly/config.dart';
import 'package:controlly/device_details.dart';
import 'package:controlly/homeassistant/homeassistant.dart';
import 'package:controlly/page_builder.dart';
import 'package:controlly/settings/model.dart';
import 'package:controlly/settings/view.dart';
import 'package:controlly/store.dart';
import 'package:controlly/user_config.dart';
import 'package:controlly/websocket_server/server.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:uni_links/uni_links.dart';

void main() {
  runApp(const MyApp());

  // Intialize device listeners
  var deviceInfo = DeviceDetails();
  deviceInfo.initialize();

  // Initialize WebSocket server
  var wss = WebSocketServer();
  wss.initialize();
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
        fontFamily: 'Roboto',
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
  StreamSubscription? _linkSub;

  Future<void> initUniLinks() async {
    // Attach a listener to the stream
    _linkSub = uriLinkStream.listen((Uri? link) {
      // links are registered as controlly://main/path
      // scheme is 'controlly'
      // host/authority is 'main'
      developer.log('Link: $link');
      developer.log('Authority: ${link!.authority}');
      developer.log('Path: ${link.path}');
      developer.log('Query: ${link.queryParameters}');
      if (link.path == '/auth-callback') {
        String? code = link.queryParameters['code'];
        if (code == null) {
          developer.log('No code in query parameters');
          return;
        }
        store.ha!.getTokens(code).then((_) {
          store.ha!.connect();
        });
      }
      Config.navigatorKey.currentState?.push(MaterialPageRoute(
        builder: (context) {
          return HassAuthConfirm(link);
        },
      ));
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
  }

  Future launch(BuildContext context, Widget page) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (context) => page));
    refresh();
  }

  @override
  void initState() {
    // store.ha.updates.listen()
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    checkSettings();
    initUniLinks();
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  void refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  void checkSettings() async {
    await settingsManager.ready;
    if (settingsManager.getItem('haHost')?.isNotEmpty ?? false) {
      // attempt to connect
      store.ha?.destroy();
      store.ha = HomeAssistant(HomeAssistantSettings(
        ip: settingsManager.getItem('haHost'),
        port: int.tryParse(settingsManager.getItem('haPort')) ?? 8123,
        ssl: settingsManager.getItem('haSSL'),
        longLivedToken: settingsManager.getItem('haToken'),
        expiringAccessToken: settingsManager.haSettings['expiringAccessToken'] ?? '',
        refreshToken: settingsManager.haSettings['refreshToken'] ?? '',
        expiresIn: Duration(seconds: settingsManager.haSettings['expiresIn'] ?? 0),
        tokenTime: DateTime.fromMillisecondsSinceEpoch(settingsManager.haSettings['tokenTime'] ?? 0),
      ));
      await store.ha!.connect();
    }
    // load user configuration
    if (await loadUserConfig()) {
      refresh();
    }
  }

  void haUpdateHandler() {}

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  void pageSelected(int index) {
    setState(() {
      currentPageIndex = index;
      pageController.animateToPage(index, duration: const Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  void pageChanged(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => loadUserConfig().then((_) => refresh()),
          ),
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
                var pages = <Widget>[];
                store.userConfig['pages'].forEach((key, value) {
                  pages.add(PageWidget(pageConfig: value));
                });
                return PageView(
                  children: pages,
                  controller: pageController,
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: (store.userConfig['pages'] ?? []).length > 2
          ? BottomNavigationBar(
              currentIndex: currentPageIndex,
              type: BottomNavigationBarType.fixed,
              items: buildBottomBarItems(),
              onTap: (index) {
                pageSelected(index);
              },
            )
          : null,
    );
  }

  List<BottomNavigationBarItem> buildBottomBarItems() {
    var navBarItems = <BottomNavigationBarItem>[];
    if (store.userConfig['pages'] == null) return [];
    store.userConfig['pages'].forEach((key, page) {
      navBarItems.add(BottomNavigationBarItem(
        icon: Icon(MdiIcons.fromString(page['icon'] ?? 'folder')),
        label: page['title'] ?? key,
      ));
    });

    return navBarItems;
  }
}
