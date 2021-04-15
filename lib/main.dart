import 'dart:async';

import 'package:esense_flutter/esense.dart';
import 'package:esense_test/movement.dart';
import 'package:esense_test/pomodoro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eSense Test',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(title: 'eSense connection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _deviceStatus = 'unknown';
  var _deviceName = 'unknown';

  ESenseManager manager = ESenseManager();

  StreamSubscription subscription;

  Movement movement = new Movement();

  Pomodoro pomo;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override void initState() {
    super.initState();
    pomo = new Pomodoro(callback: () => _pomoAlarm());
    _connectTest();
  }

  Future<void> _connectTest() async {

    bool con = false;

    manager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');
      if (event.type == ConnectionType.connected) {
        _listenToESenseEvents();
        _sensorEvents();
      }

      setState(() {
        switch (event.type) {
          case ConnectionType.connected:
            _deviceStatus = 'connected';
            break;
          case ConnectionType.unknown:
            _deviceStatus = 'unknown';
            break;
          case ConnectionType.disconnected:
            _deviceStatus = 'disconnected';
            break;
          case ConnectionType.device_found:
            _deviceStatus = 'device_found';
            break;
          case ConnectionType.device_not_found:
            _deviceStatus = 'device_not_found';
            break;
        }
      });
    });
    con = await manager.connect('esense-left');

    setState(() {
      _deviceStatus = con ? 'connecting' : 'connection failed';
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_deviceStatus',
              style: Theme.of(context).textTheme.headline4,
            ),
            Text(
              '$_deviceName',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sensorEvents,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _listenToESenseEvents() {
  manager.eSenseEvents.listen((event) {
    print('Event: $event');
    setState(() {
      switch (event.runtimeType) {
        case DeviceNameRead:
          _deviceName = (event as DeviceNameRead).deviceName;
          break;
      }
    });
  });
  _loopGetProps();
  //_sensorEvents();
  }

  void _loopGetProps() async {
    await manager.getDeviceName();
    await manager.setSamplingRate(10);
  }

  void _sensorEvents() async {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
    else {
      subscription = manager.sensorEvents.listen((event) {
        List<int> acc = event.accel;

        movement.update(acc);
        print(movement.movementPercent());

        print('SENSOR event: $event');
        setState(() {
          _deviceName = pomo.getTimer();
        });
      });
      print("Listening to Sensors. ${subscription.hashCode}");
      pomo.start();
    }
    }

  void _pomoAlarm() {
    setState(() {
      _deviceStatus = pomo.state.toString();
    });
  }
}

