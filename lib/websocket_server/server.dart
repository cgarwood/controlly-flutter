import 'dart:convert';
import 'dart:io';
import 'package:controlly/store.dart';

class WebSocketServer {
  void initialize() async {
    HttpServer server = await HttpServer.bind(InternetAddress.anyIPv4, 5600);
    server.transform(WebSocketTransformer()).listen(onWebSocketData);
  }

  void onWebSocketData(WebSocket client) {
    client.listen((rawData) {
      var data = jsonDecode(rawData);
      if (data['command'] != null) {
        switch (data['command']) {
          case "hello":
            client.add(jsonEncode({"command": "hello", "result": "Hello from Controlly!"}));
            break;
          case "device_info":
            client.add(jsonEncode({
              "command": "device_info",
              "device": store.device,
            }));
            break;
          default:
            client.add(jsonEncode({"command": "error", "data": "unknown command"}));
        }
      } else {
        client.add(jsonEncode({"command": "error", "data": "no command specified"}));
      }
    });
  }
}
