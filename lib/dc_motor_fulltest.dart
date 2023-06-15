import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:controller_flutter_project/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:web_socket_channel/io.dart';

import 'connection.dart';

class DcMotorFullTest extends StatefulWidget {
  DcMotorFullTest({Key? key, required this.channel, required this.connected})
      : super(key: key);
  IOWebSocketChannel channel;
  bool connected;

  @override
  State<DcMotorFullTest> createState() => _DcMotorFullTestState();
}

class _DcMotorFullTestState extends State<DcMotorFullTest> {
  Text counter(double value) {
    return Text(
      '${value.toInt()}%',
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w200, fontSize: 35),
    );
  }

  ValueNotifier<double> valueNotifiers = ValueNotifier<double>(100);

  double currentVal = 0;
  double width = 110;
  double hight = 110;
  String clockWise = "ClockWise...";
  late Timer _timer;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      setState(() {
        if (clockWise == 'ClockWise...') {
          sendcmd("A");
          sendcmd("100");
          clockWise = 'Anti-ClockWise...';
        } else if (clockWise == 'Anti-ClockWise...') {
          sendcmd("B");
          sendcmd("100");
          clockWise = '100% Speed...';
        } else if (clockWise == '100% Speed...') {
          sendcmd("100");
          clockWise = '80% Speed...';
        } else if (clockWise == '80% Speed...') {
          sendcmd("80");
          clockWise = '60% Speed...';
        } else if (clockWise == '60% Speed...') {
          sendcmd("60");
          clockWise = '40% Speed...';
        } else if (clockWise == '40% Speed...') {
          sendcmd("40");
          clockWise = 'Test Finish!';
        } else if (clockWise == 'Test Finish!') {
          sendcmd("0");
          Navigator.of(context, rootNavigator: true).pop();
        }
      });
    });
  }

  Future<void> sendcmd(String cmd) async {
    widget.channel.sink.add(cmd); //sending Command to NodeMCU
    print(cmd);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 47, 47, 47),
      body: Center(
          child: Column(
        children: [
          SizedBox(
            height: 40,
          ),
          SizedBox(height: 80),
          SimpleCircularProgressBar(
            valueNotifier: valueNotifiers,
            backStrokeWidth: 17,
            progressStrokeWidth: 17,
            progressColors: const [
              Color.fromARGB(255, 70, 159, 232),
              Colors.green,
            ],
            size: 250,
            animationDuration: 18,
            backColor: Colors.white,
            mergeMode: true,
            onGetText: counter,
          ),
          SizedBox(
            height: 50,
          ),
          Text(
            clockWise,
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w200, fontSize: 30),
          ),
          SizedBox(
            height: 50,
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
                Navigator.of(context).pop();
              },
              color: Color.fromARGB(255, 37, 37, 37),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_back_ios_sharp,
                    size: 10,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Control Mode",
                    style: TextStyle(
                        fontWeight: FontWeight.w200,
                        fontSize: 20,
                        color: Colors.white),
                  )
                ],
              ),
            ),
          )
        ],
      )),
    );
  }
}
