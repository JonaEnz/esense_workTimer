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
  String _deviceStatus = 'unknown';
  var _deviceName = 'unknown';

  final GlobalKey<FormState> _keyDialogForm = new GlobalKey<FormState>();
  Color _faColor = Colors.red;

  ESenseManager manager = ESenseManager();

  StreamSubscription subscription;

  Movement movement = new Movement();

  Pomodoro pomo;

  int _sensorEventsReceived;

  int _moveCount = 0;

  @override void initState() {
    super.initState();
    pomo = new Pomodoro(callback: () => _pomoAlarm());
    if(manager.connected) manager.disconnect();
    if (subscription != null) subscription.cancel();
    //_connectTest();
  }

  Future<void> _connectTest(eSenseName) async {

    bool con = false;

    manager.connectionEvents.listen((event) {
      print('CONNECTION event: $event');
      if (event.type == ConnectionType.connected) {
        Timer(Duration(milliseconds: 500), () {
          _listenToESenseEvents();

        });
        Timer(Duration(seconds: 2), () {
          _sensorEvents();
        });
        setState(() {
          _faColor = Colors.green;
        });
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
    con = await manager.connect(eSenseName);

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
        onPressed: _showDialog,
        tooltip: 'Connect',
        backgroundColor: _faColor,
        child: Icon(Icons.bluetooth),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _showDialog() {
    setState(() {
      {
        showDialog(builder: (BuildContext context) {
          return AlertDialog(
            title: Form(
              key: _keyDialogForm,
              child: Column(
                children: <Widget>[
                  Text("Input eSense name:"),
                  TextFormField(
                    initialValue: "esense-left",
                    onSaved: (value) {
                      _connectTest(value);
                    },
                  )
                ],
              ),
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  //TODO: Implement me!
                  _keyDialogForm.currentState.save();
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),

            ],
          );
        },
            context: context);
      }
    });
  }

  void _listenToESenseEvents() {
  manager.eSenseEvents.listen((event) {
    print('Event: $event');
    setState(() {
      switch (event.runtimeType) {
        case DeviceNameRead:
          _deviceName = (event as DeviceNameRead).deviceName;
          break;
        case ButtonEventChanged:
          var pressed = (event as ButtonEventChanged).pressed;
          if (pressed && pomo.isPaused()) {
            if (pomo.canStart()) {
              pomo.start();
            } else {
              if(pomo.unlock(999999999)) pomo.start();
            }
          } else if (pressed) {
            //pomo.pause();
            //TODO: Implement Pause with timer
          }
          break;
      }
    });
  });
  //_sensorEvents();
  }

  void _sensorEvents() async {
    print("_sensorEvents");
    pomo.start();
    _tryListening();
    }

    void _tryListening() {
      subscription = manager.sensorEvents.listen(_handleSensorEvent);
      print("Listening to Sensors. ${subscription.hashCode}");
      _sensorEventsReceived = 0;
      Timer(Duration(seconds: 3), () async {
        if (_sensorEventsReceived < 2) {
          await subscription.cancel();
          print("reconnecting...");
          _tryListening();
        }
      });
    }

    Function _handleSensorEvent(SensorEvent event) {
      List<int> acc = event.accel;

      movement.update(acc);
      print(movement.movementPercent());

      if (pomo.getState() != PomoState.Work) {
        _moveCount += movement.isMoving() ? 1 : 0;
      }

      setState(() {
        var percentage = (100 * (_moveCount / pomo.getMoveGoal())).floor();
        _deviceStatus = "Moved: ${percentage >= 100 ? 100 : percentage}%";
      });

      if (!pomo.canStart()) {
        pomo.unlock(_moveCount);
      }

      print('SENSOR event: $event');
      _sensorEventsReceived++;
      setState(() {
        _deviceName = pomo.getTimer();
      });
      return null;
    }

  void _pomoAlarm() {
    _moveCount = 0;
    setState(() {
      //_deviceStatus = pomo.getState().toString();
    });
  }
}

