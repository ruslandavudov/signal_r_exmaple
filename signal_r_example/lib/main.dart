import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
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
  final _url = 'https://app.vmireapp.ru/online?access_token=';

  HubConnection? hubConnection;
  late bool _isConnected;
  late bool _isInitHub;
  final _formKey = GlobalKey<FormBuilderState>();
  final List<String> _messages = <String>[];
  final ScrollController _controller = ScrollController();
  String _serverReply = '';

  @override
  void initState() {
    _isConnected = false;
    _isInitHub = false;

    super.initState();
  }

  @override
  void dispose() {
    if (mounted) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void _initHub(String accessToken) {
    final url = _url + accessToken;

    setState(() {
      _serverReply = '';
      _messages.clear();
    });
    hubConnection?.stop();
    hubConnection = HubConnectionBuilder()
        .withUrl(
            url,
            HttpConnectionOptions(
              logMessageContent: true,
              logging: (level, message) {
                print('[logging] $message');

                Future.delayed(const Duration(seconds: 1), () {
                  setState(() {
                    _messages.add(message);
                    if (_messages.length > 300) {
                      _messages.removeAt(0);
                    }
                  });

                  _scrollDown();
                });
              },
            ))
        .build();

    setState(() {
      _isInitHub = true;
    });

    hubConnection?.onclose((exception) {
      setState(() {
        _isConnected = false;
      });
      // hubConnection = null;
    });
    hubConnection?.on('ServerReply', (message) {
      print('[on ServerReply] ${message.toString()}');
      var reply = '';
      message?.forEach((e) => reply += e.toString());

      setState(() {
        _serverReply = reply;
      });
    });
  }

  Future<void> _disconnect() async {
    await hubConnection?.stop().then((result) async {
      setState(() {
        _isConnected = hubConnection?.state == HubConnectionState.connected;
      });
    });
  }

  Future<void> _connect() async {
    await hubConnection?.start()?.then((result) async {
      setState(() {
        _isConnected = hubConnection?.state == HubConnectionState.connected;
      });
    });
  }

  // Future<void> _invoke() async {
  //   await hubConnection?.invoke('Register', args: ['79001112233']);
  // }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState?.fields['access_token']
                          ?.didChange('');
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.grey,
                      child: const Center(
                        child: Text(
                          'clear',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _formKey.currentState?.save();
                      final formBuilderState = _formKey.currentState;
                      final value = formBuilderState!.value;
                      final accessToken = value['access_token'] as String?;
                      _initHub(accessToken ?? '');
                    },
                    child: Container(
                      width: 100,
                      height: 50,
                      color: Colors.teal,
                      child: const Center(
                        child: Text(
                          'init hub',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _isInitHub
                        ? (() async => _isConnected
                            ? await _disconnect()
                            : await _connect())
                        : null,
                    child: Container(
                      width: 100,
                      height: 50,
                      color: _isInitHub
                          ? (_isConnected ? Colors.blue : Colors.green)
                          : Colors.grey,
                      child: Center(
                        child: Text(
                          _isInitHub && _isConnected ? 'Disconnect' : 'Connect',
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  // TextButton(
                  //   onPressed: () async => _isConnected ? await _invoke() : null,
                  //   child: Container(
                  //     width: 100,
                  //     height: 50,
                  //     color: Colors.grey,
                  //     child: const Center(
                  //       child: Text(
                  //         'Invoke',
                  //         style: TextStyle(color: Colors.black),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              FormBuilder(
                key: _formKey,
                child: SingleChildScrollView(
                  child: FormBuilderTextField(
                    name: 'access_token',
                    maxLines: 10,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.all(8),
                      border: InputBorder.none,
                      hintText: 'access token',
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 200,
                child: ListView(
                  controller: _controller,
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: List.generate(_messages.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        _messages[index],
                        style: const TextStyle(color: Colors.black),
                      ),
                    );
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    _serverReply,
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
