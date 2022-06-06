import 'package:flutter/material.dart';
import 'package:signalr_core/signalr_core.dart';

// import 'package:logging/logging.dart';
// import 'package:signalr_netcore/signalr_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo application for SignalR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Demo application for SignalR'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _url = 'https://app.vmireapp.ru/online?id=IlvhIPnBEwoYe1XS0T0YTw';

  late HubConnection hubConnection;
  late bool _isConnected;

  @override
  void initState() {
    _isConnected = false;
    hubConnection = HubConnectionBuilder()
        .withUrl(
            _url,
            HttpConnectionOptions(
              logMessageContent: true,
              logging: (level, message) {
                print(message);
              },
            ))
        .build();

    hubConnection.on('ServerReply', (message) {
      print(message.toString());
    });

    super.initState();
  }

  Future<void> _disconnect() async {
    await hubConnection.stop().then((result) async {
      setState(() {
        _isConnected = hubConnection.state == HubConnectionState.connected;
      });
    });
  }

  Future<void> _connect() async {
    await hubConnection.start()?.then((result) async {
      setState(() {
        _isConnected = hubConnection.state == HubConnectionState.connected;
      });
    });
  }

  Future<void> _invoke() async {
    await hubConnection.invoke('Register', args: ['79001112233']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
              onPressed: () async =>
                  _isConnected ? await _disconnect() : await _connect(),
              child: Container(
                width: 100,
                height: 50,
                color: _isConnected ? Colors.blue : Colors.green,
                child: Center(
                  child: Text(
                    _isConnected ? 'Disconnect' : 'Connect',
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async => _isConnected ? await _invoke() : null,
              child: Container(
                width: 100,
                height: 50,
                color: Colors.grey,
                child: const Center(
                  child: Text(
                    'Invoke',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
