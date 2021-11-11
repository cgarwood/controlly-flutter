import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:controlly/homeassistant/entities/binary_sensor.dart';
import 'package:controlly/homeassistant/entities/climate.dart';
import 'package:controlly/homeassistant/entities/light.dart';
import 'package:controlly/homeassistant/entities/sensor.dart';
import 'package:controlly/homeassistant/entities/switch.dart';
import 'package:controlly/homeassistant/entity.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../config.dart';
import '../utils/ws.dart';
import '../settings/model.dart';

enum ComponentConnectionStatus { disconnected, connecting, connected, failed }

class HomeAssistantSettings {
  String ip;
  int port;
  bool ssl;

  String longLivedToken;
  String expiringAccessToken;
  String refreshToken;
  Duration expiresIn;
  DateTime tokenTime;

  bool get authorized => (longLivedToken.isNotEmpty) || (refreshToken.isNotEmpty);
  String get accessToken => longLivedToken.isNotEmpty ? longLivedToken : expiringAccessToken;
  bool get shouldRefresh => tokenTime.add(expiresIn).isBefore(DateTime.now()) != false; // null or true => true

  HomeAssistantSettings({
    this.ip = '',
    this.port = 0,
    this.longLivedToken = '',
    this.expiringAccessToken = '',
    this.refreshToken = '',
    this.expiresIn = const Duration(),
    this.ssl = false,
    DateTime? tokenTime,
  }) : tokenTime = tokenTime ?? DateTime(0);

  factory HomeAssistantSettings.fromMap(Map data) {
    var ip = data['ip'] ?? '';
    var port = data['port'] ?? 0;
    var ssl = data['ssl'] ?? false;
    var longLivedToken = data['longLivedToken'] ?? '';
    var expiringAccessToken = data['accessToken'] ?? '';
    var refreshToken = data['refreshToken'] ?? '';
    var expiresIn = Duration(seconds: data['expiresIn'] ?? 0);
    var tokenTime = DateTime.fromMillisecondsSinceEpoch(data['tokenTime'] ?? 0);
    return HomeAssistantSettings(
      ip: ip,
      port: port,
      ssl: ssl,
      longLivedToken: longLivedToken,
      expiringAccessToken: expiringAccessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      tokenTime: tokenTime,
    );
  }

  Map<String, dynamic> get asMap => {
        'ip': ip,
        'port': port,
        'ssl': ssl,
        'longLivedToken': longLivedToken,
        'accessToken': expiringAccessToken,
        'refreshToken': refreshToken,
        'expiresIn': expiresIn.inSeconds,
        'tokenTime': tokenTime.millisecondsSinceEpoch,
      };

  save() {
    settingsManager.haSettings = asMap;
  }
}

class HomeAssistant {
  // connection status
  final ValueNotifier<ComponentConnectionStatus> _status = ValueNotifier(ComponentConnectionStatus.disconnected);
  ComponentConnectionStatus get status => _status.value;
  set status(ComponentConnectionStatus newStatus) {
    _status.value = newStatus;
  }

  bool get connected => status == ComponentConnectionStatus.connected;

  // update stream for frontend widgets
  final StreamController updateController = StreamController.broadcast();
  Stream get updates => updateController.stream;

  // Home Assistant specific state variables
  HomeAssistantSettings settings;
  List<HomeAssistantEntity> entities = [];

  // Variables to handle the socket communications
  late WS ws;
  late StreamSubscription socketListener;
  late StreamSubscription socketStatusListener;

  // home assistant requests and responses always have an id
  // so they can be matched to each other... however, the response
  // does not contain the command, so we need to remember what was requested
  Map<int, Map<String, dynamic>> requests = {};
  int messageId = 1;

  HomeAssistant(this.settings) {
    ws = WS('hassSocket');
    socketStatusListener = ws.connectionStatus.listen((bool b) {
      status = b ? ComponentConnectionStatus.connected : ComponentConnectionStatus.disconnected;
    });
    socketListener = ws.listen(handler);
  }

  /// oAuth workflow is described here:
  /// https://developers.home-assistant.io/docs/auth_api/
  void authorize() {
    var uri = Uri(
      scheme: settings.ssl ? 'https' : 'http',
      host: settings.ip,
      port: settings.port,
      path: '/auth/authorize',
      queryParameters: {
        'client_id': Config.hassClientId,
        'redirect_uri': Config.hassRedirectUri,
      },
    );
    launch(uri.toString());
  }

  Future getTokens(String code) async {
    var uri = Uri(scheme: settings.ssl ? 'https' : 'http', host: settings.ip, port: settings.port, path: '/auth/token');
    var res = await http.post(uri, body: {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': Config.hassRedirectUri,
      'client_id': Config.hassClientId,
    });
    if (res.statusCode != 200) return;

    var data = json.decode(res.body);
    settings.expiringAccessToken = data['access_token'];
    settings.expiresIn = Duration(seconds: data['expires_in'] ?? 0);
    settings.refreshToken = data['refresh_token'];
    settings.tokenTime = DateTime.now();
    settings.save();
    return;
  }

  Future<void> refreshTokens() async {
    var uri = Uri(scheme: settings.ssl ? 'https' : 'http', host: settings.ip, port: settings.port, path: '/auth/token');
    try {
      var res = await http.post(uri, body: {
        'grant_type': 'refresh_token',
        'refresh_token': settings.refreshToken,
        'client_id': Config.hassClientId,
      });

      if (res.statusCode != 200) {
        authorize();
        return;
      }

      var data = json.decode(res.body);
      settings.expiringAccessToken = data['access_token'];
      settings.expiresIn = Duration(seconds: data['expires_in'] ?? 0);
      settings.tokenTime = DateTime.now();
      settings.save();
      return;
    } catch (e) {
      developer.log(e.toString());
    }
  }

  void notify() {
    updateController.add('update');
  }

  Future<void> connect() async {
    if (settings.ip.isEmpty || settings.port == 0) return;
    if (settings.refreshToken.isEmpty) {
      authorize();
      return;
    }
    if (settings.accessToken.isEmpty) {
      await refreshTokens();
    }

    if (settings.shouldRefresh) await refreshTokens();

    var protocol = (settings.ssl) ? 'wss' : 'ws';
    var url = '$protocol://${settings.ip}:${settings.port}/api/websocket';
    if (ws.connected) ws.dispose();
    socketListener.pause();
    ws.connect(
      url,
      firstMessage: WSMessage.fromMap({
        'type': 'auth',
        'access_token': settings.accessToken,
      }),
    );
    socketListener.resume();
  }

  void destroy() {
    socketListener.cancel();
    socketStatusListener.cancel();
    ws.dispose();
  }

  void handler(WSMessage message) {
    // developer.log('Homeassistant Message Handler');
    // developer.log(message.rawString);
    bool reloadStates = false;
    var data = message.rawMap;
    var requestId = data?['id'] ?? false;
    if (requestId != false && !requests[requestId]?['completer'].isCompleted) {
      requests[requestId]?['completer'].complete();
    }

    switch (data?['type']) {
      case 'auth_required':
        var msg = WSMessage()
          ..rawMap = {
            'type': 'auth',
            'access_token': settings.accessToken,
          };
        ws.send(msg);
        break;
      case 'auth_ok':
        getStates();
        subscribeEvents();
        break;
      case 'event':
        switch (data?['event']['event_type']) {
          case 'state_changed':
            var stateData = data?['event']['data'];
            try {
              var entity = entities.firstWhere((e) => e.id == stateData['entity_id']);
              entity.handleUpdate(stateData['new_state']);
              updateController.add('');
            } on StateError {
              reloadStates = true;
              developer.log('No entity handler for ${stateData['entity_id']}');
            } catch (e) {
              // developer.log(e);
            }
            break;
        }
        break;
      case 'result':
        if (!data?['success']) return;
        if (!requests.containsKey(requestId)) return;

        WSMessage requested = requests[requestId]!['message']!;
        switch (requested.rawMap?['type']) {
          case 'get_states':
            entities.clear();
            for (var result in data?['result'] ?? []) {
              var id = result['entity_id'];
              if (id == null) continue;

              var typeString = id.split('.').first;
              String name = result['attributes']?['friendly_name'] ?? id;

              dynamic hae;
              switch (typeString) {
                case 'binary_sensor':
                  hae = HomeAssistantBinarySensorEntity(id, this, result);
                  break;
                case 'switch':
                  hae = HomeAssistantSwitchEntity(id, this, result);
                  break;
                case 'climate':
                  hae = HomeAssistantClimateEntity(
                    id,
                    this,
                    result,
                  );
                  break;
                case 'light':
                  hae = HomeAssistantLightEntity(
                    id,
                    this,
                    result,
                  );
                  break;
                case 'script':
                  hae = HomeAssistantScriptEntity(name, id, this, result);
                  break;
                case 'sensor':
                  hae = HomeAssistantSensorEntity(id, this, result);
                  break;
                default:
                  // not one of the three entity types we track... abort
                  continue;
              }

              // hae might be null, so we doublecheck
              if (hae is HomeAssistantEntity) {
                hae.attributes = result['attributes'];
                entities.add(hae);
                updateController.add('');
              }
            }
        }
        break;
    }
    if (reloadStates) getStates();
  }

  // HomeAssistant uses message rawMap, not message/data format
  Future send(WSMessage message) async {
    if (settings.shouldRefresh) await refreshTokens();

    message.rawMap?['id'] = messageId;
    requests[messageId] = {
      'message': message,
      'completer': Completer(),
    };
    ws.send(message);

    return requests[messageId++]!['completer'].future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {},
        );
  }

  void subscribeEvents() {
    var msg = WSMessage.fromMap({'type': 'subscribe_events'});
    send(msg);
  }

  void getStates() {
    var msg = WSMessage.fromMap({'type': 'get_states'});
    send(msg);
  }
}

class HomeAssistantScriptEntity extends HomeAssistantSwitchEntity {
  HomeAssistantScriptEntity(name, id, parent, stateData)
      : super(
          id,
          parent,
          stateData,
        ) {
    type = HomeAssistantEntityType.scriptEntity;
  }
}
