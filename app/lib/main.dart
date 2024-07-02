import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

import './authed_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZeroTier for Magisk',
      theme: ThemeData(
        colorSchemeSeed: Colors.lightBlue,
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.lightBlue,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

Future zerotierCommand(String command) {
  return Process.run('echo', [command, '>/data/data/com.eventlowop.zerotier_magisk_app/files/pipe']);
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> networkList = [];
  bool runningStatus = false;

  final AuthedClient authed = AuthedClient();

  loadNetwork() async {
    final client = await authed.client;
    final resp = await client.get(
      Uri.http('localhost:9993', 'network'),
    );
    final body = jsonDecode(resp.body);
    networkList = List<String>.from(body.map((u) => u['id']));
  }

  void leaveNetwork(String id) async {
    final client = await authed.client;
    final resp = await client.delete(Uri.http('localhost:9993', 'network/$id'));
    if (resp.statusCode != 200) {
      // failed
      return;
    }
    // success
    setState(() {
      networkList.remove(id);
    });
  }

  void joinNetwork(String id) async {
    final client = await authed.client;
    final resp = await client.put(Uri.http('localhost:9993', 'network/$id'));
    if (resp.statusCode != 200) {
      // failed
      return;
    }
    // success
    if (!networkList.contains(id)) {
      setState(() {
        networkList.add(id);
      });
    }
  }

  Future<void> loadStatus() async {
    final client = await authed.client;
    try {
      await client.get(Uri.http('localhost:9993'));
      setState(() => runningStatus = true);
      return;
    } on SocketException {
      setState(() => runningStatus = false);
    } catch (e) {
      developer.log('error', error: e.toString());
      // error
    }
  }

  late Future<void> loadingNetworkFuture = loadNetwork();

  @override
  void initState() {
    super.initState();
    loadStatus();
  }

  Function cmdButtonWrapper(func) {
    bool doing = false;
    return () => doing
        ? null
        : () async {
            setState(() => doing = true);
            await func();
            setState(() => doing = false);
          };
  }

  late Function restartFn, startFn, stopFn, joinFn, leaveFn;

  _MyHomePageState() : super() {
    restartFn =
        cmdButtonWrapper(() => zerotierCommand('restart'));
    startFn = cmdButtonWrapper(() => zerotierCommand('start'));
    stopFn = cmdButtonWrapper(() => zerotierCommand('stop'));
    joinFn = cmdButtonWrapper(() => joinNetwork(_idInputController.text));
  }

  final _idInputController = TextEditingController();

  homePage({bool title = false}) {
    if (title) {
      return 'Status';
    }
    return Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Builder(builder: (BuildContext context) {
        final color = (runningStatus ? Colors.green : Colors.red)[200];

        return Column(children: [
          Icon(runningStatus ? Icons.play_arrow : Icons.stop, color: color, size: 72),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(runningStatus ? 'Running' : 'Stopped', style: TextStyle(color: color, fontSize: 18)),
            IconButton(icon: const Icon(Icons.refresh), onPressed: loadStatus)
          ])
        ]);
      }),
      ButtonBar(
        alignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          OutlinedButton.icon(
            onPressed: startFn(),
            label: const Text('Start'),
            icon: const Icon(Icons.play_arrow),
          ),
          OutlinedButton.icon(
            onPressed: restartFn(),
            label: const Text('Restart'),
            icon: const Icon(Icons.restart_alt),
          ),
          OutlinedButton.icon(
            onPressed: stopFn(),
            label: const Text('Stop'),
            icon: const Icon(Icons.stop),
          ),
        ],
      )
    ]);
  }

  networkPage({bool title = false}) {
    if (title) {
      return 'Network';
    }
    return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              SizedBox(
                  width: 200,
                  child: TextField(
                      controller: _idInputController,
                      textAlign: TextAlign.center,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(RegExp('[0-9a-f]'))
                      ],
                      maxLength: 16,
                      decoration: const InputDecoration(
                          labelText: "network id", icon: Icon(Icons.router)))),
              OutlinedButton.icon(
                  onPressed: joinFn(),
                  label: const Text('Join'),
                  icon: const Icon(Icons.add)),
            ]),
            const SizedBox(height: 30),
            const Divider(height: 10),
            ListTile(
                title: const Text('Networks'),
                titleTextStyle: const TextStyle(fontSize: 18),
                trailing: IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        loadingNetworkFuture = loadNetwork();
                      });
                    })),
            const SizedBox(height: 10),
            FutureBuilder<void>(
              future: loadingNetworkFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  return ListView.builder(
                      shrinkWrap: true,
                      itemCount: networkList.length,
                      itemBuilder: (BuildContext ctx, int i) {
                        return Card(
                            child: ListTile(
                                title: Text(networkList[i]),
                                trailing: SizedBox(
                                    width: 96,
                                    child: Row(children: [
                                      IconButton(
                                          onPressed: () => Clipboard.setData(
                                                  ClipboardData(
                                                      text: networkList[i]))
                                              .then,
                                          tooltip: '复制',
                                          icon: const Icon(Icons.copy)),
                                      IconButton(
                                          onPressed: () =>
                                              leaveNetwork(networkList[i]),
                                          tooltip: '离开',
                                          icon: const Icon(Icons.close)),
                                    ]))));
                      });
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ));
  }

  int currentPageIndex = 0;
  genWidgetList({bool title = false}) {
    return [
      homePage(title: title),
      networkPage(title: title)
    ][currentPageIndex];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(genWidgetList(title: true))),
        bottomNavigationBar: NavigationBar(
          onDestinationSelected: (int index) {
            setState(() {
              currentPageIndex = index;
            });
          },
          selectedIndex: currentPageIndex,
          destinations: const <Widget>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Status',
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.router),
              icon: Icon(Icons.router_outlined),
              label: 'Network',
            ),
          ],
        ),
        body: Center(
          child: genWidgetList(),
        ));
  }
}
