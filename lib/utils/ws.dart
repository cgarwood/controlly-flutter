// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:async';
import 'dart:convert';

/// the wsmessage class
class WSMessage {
  String? message;
  Map<String, dynamic>? rawMap;
  String rawString = '';
  dynamic data;

  WSMessage({
    this.message,
    this.data,
  }) {
    rawMap = {'message': message, 'data': data};
  }

  WSMessage.fromMap(Map<String, dynamic> m) {
    rawMap = m;
  }

  WSMessage.fromString(String s) {
    rawString = s;
    try {
      var tmp = json.decode(s);
      rawMap = tmp;
      message = tmp['message'] ?? '';
      data = tmp['data'] ?? '';
    } catch (e) {
      rawMap = {'message': s};
      message = s;
      data = null;
    }
  }
  String toJson() {
    if (message != null && message!.isNotEmpty) {
      return json.encode({'message': message, 'data': data});
    } else if (rawMap != null) {
      return json.encode(rawMap);
    } else {
      return rawString;
    }
  }
}

class WS {
  static int socketInstances = 0;
  int socketId;
  String niceName;
  bool connected;

  bool _usePing = true;
  bool disposed = false; // used to prevent reuse of this socket

  // nullable fields
  String? _wsUrl;
  WSMessage? _authMessage; // to allow automatic reconnections
  WebSocket? _socket;
  Timer? _heartBeatTimer;
  StreamSubscription? _socketListener;

  // streams
  final StreamController<WSMessage> _outputController;
  final StreamController<bool> _connectionStatusController;
  Stream<bool> get connectionStatus => _connectionStatusController.stream;

  WS(this.niceName)
      : _outputController = StreamController<WSMessage>(),
        _connectionStatusController = StreamController<bool>.broadcast(),
        connected = false,
        socketId = WS.socketInstances++;

  // command to connect to a websocket url
  void connect(String url, {WSMessage? firstMessage, bool usePing = true}) {
    _wsUrl = url;
    _usePing = usePing;
    _authMessage = firstMessage;
    _socketStart();
  }

  // starts a listener on this websocket url
  StreamSubscription<WSMessage> listen(Function(WSMessage) onData) {
    return _outputController.stream.listen(onData);
  }

  /// DO NOT USE THIS OBJECT after calling dispose,
  void dispose() {
    disposed = true;
    _outputController.close();
    _connectionStatusController.close();
    _socketListener?.cancel();
    _heartBeatTimer?.cancel();
    _socket?.close(4999, 'self');
    _socket = null;
  }

  void send(WSMessage message) {
    var msg = message.toJson();
    // print('WS $socketId $niceName: sending websocket message');
    // print(msg);
    if (_socket?.readyState == WebSocket.open) {
      _socket!.add(msg);
    } else {
      _heartBeat();
    }
  }

  void _heartBeat() {
    _heartBeatTimer?.cancel(); // only one heartbeat ever
    _heartBeatTimer = Timer(const Duration(seconds: 3), _heartBeat);
    if (_socket == null || _socket?.readyState == WebSocket.closed) {
      connected = false;
      _connectionStatusController.add(false);
      _socketStart(fromHeartBeat: true);
    }
  }

  void _socketStart({
    int retrySeconds = 2,
    bool fromHeartBeat = false,
    bool isAutoReconnect = false,
  }) async {
    // we only want one instance, so we close the previous one
    await _socket?.close(4999, 'self');
    _heartBeatTimer?.cancel();

    if (disposed) return;
    if (_wsUrl == null) return;

    print('WS $socketId $niceName: attempting to connect websocket: $_wsUrl');
    try {
      _socket = await WebSocket.connect(_wsUrl!);
      _connectionStatusController.add(true);
      _heartBeat();
    } catch (e) {
      print(e);
      connected = false;
      _connectionStatusController.add(false);
      var nextRetry = retrySeconds + 2;
      print('WS $socketId $niceName: connection failed, trying again in $nextRetry seconds: $_wsUrl');
      Timer(
        Duration(seconds: retrySeconds),
        () => _socketStart(retrySeconds: nextRetry),
      );
      return;
    }

    // if we make it here, the socket was created successfully
    if (_usePing) _socket?.pingInterval = const Duration(seconds: 5);

    // start / restart the listener
    await _socketListener?.cancel();
    _socketListener = _socket?.listen(
      handler,
      onDone: () {
        _heartBeatTimer?.cancel();
        retrySeconds = 2;
        connected = false;
        _connectionStatusController.add(false);

        if (_socket?.closeReason == 'self') {
          print('WS $socketId $niceName: I closed my websocket connection.');
          return;
        }

        print(_socket?.closeReason);
        print(_socket?.closeCode);
        print('WS $socketId $niceName: WEBSOCKET CONNECTION WAS CLOSED EXTERNALLY. TRYING AGAIN IN 2 SECONDS.');
        Timer(const Duration(seconds: 2), () {
          _socketStart(isAutoReconnect: true);
        });
      },
      cancelOnError: false,
    );

    // send our first message
    if (_authMessage != null) {
      send(_authMessage!);
    }
  }

  void handler(data) {
    print('WS $socketId $niceName: message received.');
    print(data);
    var message = WSMessage.fromString(data);
    _outputController.add(message);
  }
}
