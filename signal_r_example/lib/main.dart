import 'package:flutter/material.dart';


// import 'dart:io';
// import 'package:signalr_core/signalr_core.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  int _counter = 0;

  final _url = 'https://app.vmireapp.ru';

  Future<void> _incrementCounter() async {

    Logger.root.level = Level.ALL;

    Logger.root.onRecord.listen((LogRecord rec) {
      print('${rec.level.name}: ${rec.time}: ${rec.message}');
    });

    final hubProtLogger = Logger("SignalR - hub");

    final transportProtLogger = Logger("SignalR - transport");

    final connectionOptions = HttpConnectionOptions();
    final httpOptions = HttpConnectionOptions(logger: transportProtLogger);

    final hubConnection = HubConnectionBuilder().withUrl(_url, options: httpOptions).configureLogging(hubProtLogger).build();

    // hubConnection.onclose((error) => print("Connection Closed"));
    hubConnection.onclose(_onClose);

    await hubConnection.start();
    // final connection = HubConnectionBuilder().withUrl('https://app.vmireapp.ru',
    //     HttpConnectionOptions(
    //       logging: (level, message) => print(message),
    //     )).build();
    //
    // await connection.start();
    //
    // connection.on('ReceiveMessage', (message) {
    //   print(message.toString());
    // });
    //
    // await connection.invoke('SendMessage', args: ['Bob', 'Says hi!']);
  }

  void _onClose({Exception? error}) {
    print("Connection Closed");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
