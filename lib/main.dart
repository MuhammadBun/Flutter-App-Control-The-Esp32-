import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

import 'connection.dart';
import 'dc_motor_fulltest.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  late bool ledstatus; //boolean value to track LED status, if its ON or OFF
  late IOWebSocketChannel channel;
  late bool connected; //boolean value to track if WebSocket is connected
  TextEditingController controller = TextEditingController();
  late int volt = 0;

  @override
  void initState() {
    ledstatus = false; //initially leadstatus is off so its FALSE
    connected = false; //initially connection status is "NO" so its FALSE

    Future.delayed(Duration.zero, () async {
      ConnectionToEsp32().channelconnect(); //connect to WebSocket wth NodeMCU
    });
    super.initState();
  }

  channelconnect() {
    //function to connect
    try {
      channel =
          IOWebSocketChannel.connect("ws://192.168.0.1:81"); //channel IP : Port
      channel.stream.listen(
        (message) {
          print(message);
          setState(() {
            if (message == "connected") {
              connected = true; //message is "connected" from NodeMCU
            }
          });
        },
        onDone: () {
          //if WebSocket is disconnected
          print("Web socket is closed");
          setState(() {
            connected = false;
          });
        },
        onError: (error) {
          print(error.toString());
        },
      );
    } catch (_) {
      print("error on connecting to websocket.");
    }
  }

  Future<void> sendcmd(String cmd) async {
    if (connected == true) {
      channel.sink.add(cmd); //sending Command to NodeMCU
      print(cmd);
    } else {
      channelconnect();
      print("Websocket is not connected.");
    }
  }

  Color? colorStatus(double speed) {
    speed < 40
        ? Colors.green
        : speed > 40 && speed < 70
            ? Colors.amber
            : speed > 70 && speed < 100
                ? Colors.red
                : Colors.white;
  }

  double _clocCurrentSliderValue = 30;
  //double _anitCcurrentSliderValue = 20;
  Color speed = Colors.black;
  //Color speed1 = Colors.black;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 47, 47, 47),
      appBar: AppBar(
          title: Text("Power Electronics Project"),
          backgroundColor: Color.fromARGB(255, 34, 34, 34)),
      body: Container(
          alignment: Alignment.topCenter, //inner widget alignment to center
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                  child: connected
                      ? Text(
                          "CONNECTED",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              fontSize: 15),
                        )
                      : Text(
                          "DISCONNECTED",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 234, 234, 173),
                              fontSize: 15),
                        )),
              SizedBox(
                height: 10,
              ),
        
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Clockwise Speed Ratio:",
                      style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          fontSize: 15)),
                  SizedBox(
                    width: 5,
                  ),
                  Text("$_clocCurrentSliderValue",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: speed,
                          fontSize: 15))
                ],
              )),
              SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Slider(
                    activeColor: speed,
                    thumbColor: speed,
                    inactiveColor: Colors.black.withOpacity(0.3),
                    value: _clocCurrentSliderValue,
                    min: 30,
                    max: 100,
                    divisions: 10,
                    label: _clocCurrentSliderValue.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        _clocCurrentSliderValue = value;
                        speed = _clocCurrentSliderValue < 58 ||
                                _clocCurrentSliderValue == 58
                            ? Colors.green
                            : _clocCurrentSliderValue > 58 &&
                                        _clocCurrentSliderValue < 80 ||
                                    _clocCurrentSliderValue == 80 || _clocCurrentSliderValue > 80 && _clocCurrentSliderValue < 90
                                ? Colors.amber
                                : _clocCurrentSliderValue > 90 &&
                                            _clocCurrentSliderValue < 100 ||
                                        _clocCurrentSliderValue == 100
                                    ? Colors.red
                                    : Colors.white;
                        sendcmd('${_clocCurrentSliderValue.toInt()}');
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: MaterialButton(
                        splashColor: Colors.green,
                        hoverColor: Colors.red,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        minWidth: 140,
                        height: 50,
                        onPressed: () {
                          //on button press
                          if (ledstatus) {
                            sendcmd("A");
                            sendcmd('${_clocCurrentSliderValue.toInt()}');
                            ledstatus = false;
                          } else {
                            sendcmd("B");
                            sendcmd('${_clocCurrentSliderValue.toInt()}');
                            ledstatus = true;
                          }
                          setState(() {});
                        },
                        color: Color.fromARGB(255, 37, 37, 37),
                        child: ledstatus
                            ? Text("ClockWise",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: Colors.white))
                            : Text("Anti-ClockWise",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 15,
                                    color: Colors.white))),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 100),
                    child: MaterialButton(
                      splashColor: Colors.green,
                      hoverColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      minWidth: 140,
                      height: 50,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) => DcMotorFullTest(
                              channel: channel,
                              connected: connected,
                            ),
                          ),
                        );
                      },
                      color: Color.fromARGB(255, 37, 37, 37),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Test Mode",
                            style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 15,
                                color: Colors.white),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_outlined,
                            size: 10,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),SizedBox(height: 50,),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("PORT: ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15)),
                  SizedBox(
                    width: 5,
                  ),
                  Text("81",
                      style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          fontSize: 15))
                ],
              )),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Status: ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15)),
                  SizedBox(
                    width: 5,
                  ),
                  Text(connected?"Connected":"Disconnected",
                      style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          fontSize: 15))
                ],
              )),
              Container(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Channel IP: ",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15)),
                  SizedBox(
                    width: 5,
                  ),
                  Text("ws://192.168.0.1:81",
                      style: TextStyle(
                          fontWeight: FontWeight.w200,
                          color: Colors.white,
                          fontSize: 15))
                ],
              ))
            ],
          )),
    );
  }
}
