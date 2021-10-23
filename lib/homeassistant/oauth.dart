import 'dart:convert';

import 'package:controlly/config.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import './homeassistant.dart';

// import 'package:oauth2/oauth2.dart' as oath2;

/*
app.get('/login', function(req, res) {
var scopes = 'user-read-private user-read-email';
res.redirect('https://accounts.spotify.com/authorize' +
  '?response_type=code' +
  '&client_id=' + my_client_id +
  (scopes ? '&scope=' + encodeURIComponent(scopes) : '') +
  '&redirect_uri=' + encodeURIComponent(redirect_uri));
});
*/

class HassOAuth2Page extends StatefulWidget {
  final HomeAssistantSettings settings;
  final Uri response;
  const HassOAuth2Page(this.settings, this.response);

  @override
  _HassOAuth2PageState createState() => _HassOAuth2PageState();
}

// pop this page when we open the oauth page
class _HassOAuth2PageState extends State<HassOAuth2Page> {
  String? code;
  String? state;

  void authorizeHass() {
    var uri = Uri(
      scheme: widget.settings.ssl ? 'https' : 'http',
      host: widget.settings.ip,
      port: widget.settings.port,
      path: '/auth/authorize',
      queryParameters: {
        'client_id': Config.hassClientId,
        'redirect_uri': Config.hassRedirectUri,
        'state': 'random string',
      },
    );
    launch(uri.toString());
  }

  void getTokens(String code) async {
    var uri = Uri(
        scheme: widget.settings.ssl ? 'https' : 'http',
        host: widget.settings.ip,
        port: widget.settings.port,
        path: '/auth/token');
    var res = await http.post(uri, body: {
      'grant_type': 'authorization_code',
      'code': code,
      'redirect_uri': 'controlly://main/hass',
      'client_id': Config.hassClientId,
    });
    var data = json.decode(res.body);
    print(data['access_token']);
    print(data['token_type']);
    print(data['expires_in']);
    print(data['refresh_token']);
  }

  @override
  void initState() {
    super.initState();
    code = widget.response.queryParameters['code'];
    // should match the state of the request
    state = widget.response.queryParameters['state'];

    // if we have a code, then we need to convert it to a refresh and access token
    if (code != null) {
      getTokens(code!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OAuth2 Testing'),
      ),
      body: Column(
        children: <Widget>[
          Text(widget.response.toString()),
          ElevatedButton(
            onPressed: () {
              authorizeHass();
              Navigator.of(context).pop();
            },
            child: const Text('hass'),
          )
        ],
      ),
    );
  }
}
